<?php
declare(strict_types=1);

/**
 * Generate a random integer within a specified range.
 *
 * @param int $min The minimum value (inclusive)
 * @param int $max The maximum value (inclusive)
 * @return int The random integer
 * @throws RuntimeException If the range is invalid or random bytes cannot be generated
 */
function generateRandomInt(int $min, int $max): int
{
    $range = $max - $min;
    if ($range < 0 || $range > PHP_INT_MAX) {
        throw new RuntimeException("Invalid range");
    }

    try {
        $randomBytes = random_bytes(4);
    } catch (Exception $e) {
        throw new RuntimeException("Unable to generate random bytes", 0, $e);
    }

    $randomInt = unpack('L', $randomBytes)[1] & 0x7FFFFFFF;
    return $min + ($randomInt % ($range + 1));
}

// Parse command line arguments
if ($argc < 3) {
    echo "Usage: php " . $argv[0] . " <min> <max> [count]\n";
    exit(1);
}

$min = (int) $argv[1];
$max = (int) $argv[2];
$count = isset($argv[3]) ? (int) $argv[3] : 1;

// Generate and output random numbers
for ($i = 0; $i < $count; $i++) {
    try {
        echo generateRandomInt($min, $max) . PHP_EOL;
    } catch (RuntimeException $e) {
        echo "Error: " . $e->getMessage() . PHP_EOL;
        exit(1);
    }
}
