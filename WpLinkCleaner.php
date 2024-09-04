<?php
// Take care with caution! I will not be responsible for any data loss or damage.
// Ensure script is run from the command line
if (php_sapi_name() !== 'cli') {
    die("This script must be run from the command line.");
}

// Disable execution time limit
set_time_limit(0);

// Load WordPress
$wp_load_path = realpath(__DIR__ . '/wp-load.php');
if (!file_exists($wp_load_path)) {
    die("WordPress load file not found. Please run this script from the WordPress root directory.");
}
require_once($wp_load_path);

// Display warning and get confirmation
echo "WARNING: This script will remove specific links from published WordPress posts." . PHP_EOL;
echo "Make sure you have a backup of your database before proceeding." . PHP_EOL;
echo "Do you want to continue? (yes/no): ";

$handle = fopen("php://stdin", "r");
$line = fgets($handle);
if (strtolower(trim($line)) !== 'yes') {
    echo "Script aborted." . PHP_EOL;
    fclose($handle);
    exit;
}
fclose($handle);

// Check if file exists and is readable
$file_path = __DIR__ . '/file.csv';
if (!is_readable($file_path)) {
    die("Error: Cannot read the file '$file_path'. Please check if it exists and has correct permissions.");
}

$links = file($file_path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

if ($links === false) {
    die("Error reading the file.");
}

global $wpdb;

// Start transaction
$wpdb->query('START TRANSACTION');

try {
    foreach ($links as $link) {
        $link = trim($link);
        
        if (empty($link)) continue;

        $post_ids = $wpdb->get_col($wpdb->prepare(
            "SELECT ID FROM $wpdb->posts WHERE post_type = %s AND post_status = %s AND post_content LIKE %s",
            'post',
            'publish',
            '%' . $wpdb->esc_like($link) . '%'
        ));

        $updatedPosts = [];

        foreach ($post_ids as $post_id) {
            $post = get_post($post_id);
            $content = $post->post_content;
            
            $pattern = "/<a[^>]*?href=[\"']" . preg_quote($link, '/') . "[\"'][^>]*?>(.*?)<\/a>/si";
            $original_content = $content;
            $content = preg_replace($pattern, '$1', $content);

            if ($content !== $original_content) {
                $update_result = wp_update_post(array(
                    'ID' => $post_id,
                    'post_content' => $content
                ), true);

                if (is_wp_error($update_result)) {
                    throw new Exception("Error updating post $post_id: " . $update_result->get_error_message());
                } else {
                    $updatedPosts[] = $post_id;
                }
            }
        }

        if (!empty($updatedPosts)) {
            echo "Link removed: " . htmlspecialchars($link, ENT_QUOTES, 'UTF-8') . PHP_EOL;
            echo "Updated posts: " . implode(', ', $updatedPosts) . PHP_EOL . PHP_EOL;
        }
    }

    // If we've made it this far without exceptions, commit the transaction
    $wpdb->query('COMMIT');
    echo "Script execution completed successfully." . PHP_EOL;

} catch (Exception $e) {
    // If an error occurred, roll back the transaction
    $wpdb->query('ROLLBACK');
    echo "An error occurred: " . $e->getMessage() . PHP_EOL;
    echo "All changes have been rolled back." . PHP_EOL;
}
