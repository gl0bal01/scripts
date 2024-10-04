#!/bin/bash

# gl0bal01 - KaboomKaboodle.sh
# Description:
# A playful script designed to create a maze-like folder
# structure containing hidden "story" and "flag" files. At each depth level, it
# adds a word from a story and a character from a flag, hiding them inside
# uniquely named folders.
# Users can reveal the full hidden story and a secret flag by navigating
# through the folder maze. The script provides commands to concatenate the
# files and reveal both the story and flag at the end of the run.

# Function to create folders and hidden files recursively
create_folders() {
    local depth=$1
    local path=$2

    # The "story" is an array of words, each word is hidden in a separate folder
    local story=(
        "Once" "upon" "a" "time" "in" "a" "land" "far" "away" "there"
        "lived" "a" "curious" "explorer" "who" "loved" "to" "solve"
        "puzzles" "and" "uncover" "hidden" "treasures" "One" "day"
        "they" "stumbled" "upon" "an" "ancient" "map" "that" "led"
        "to" "a" "mysterious" "labyrinth" "of" "folders" "Each" "one"
        "contained" "a" "clue" "to" "the" "next" "As" "they" "delved"
        "deeper" "into" "the" "maze" "they" "realized" "that" "the"
        "journey" "itself" "was" "the" "real" "treasure" "Teaching"
        "them" "patience" "and" "perseverance" "At" "last" "they"
        "reached" "the" "final" "folder" "and" "found" "the" "ultimate"
        "secret" "hidden" "in" "plain" "sight" "all" "along"
    )

    # The "flag" is an array of characters that combine to form a hidden message
    local flag=(
        "}" "D" "H" "D" "A" "_" "v" "_" "I" "_" "p" "l" "e" "H" "_"
        "r" "_" "U" "_" "r" "o" "F" "_" "k" "n" "a" "h" "T" "{"
        "g" "a" "l" "f"
    )

    # Base case: stop recursion when depth reaches 100
    if [ $depth -eq 100 ]; then
        return
    fi

    # Create a new folder for the current depth
    local new_folder="${path}/folder_${depth}"
    mkdir -p "$new_folder"

    # Add a hidden story file if there are still words in the story array
    if [ $depth -lt ${#story[@]} ]; then
        echo "${story[$depth]}" > "${new_folder}/.story_${depth}"
    fi

    # Add a hidden flag file if there are still characters in the flag array
    if [ $depth -lt ${#flag[@]} ]; then
        echo "${flag[$depth]}" > "${new_folder}/.flag_${depth}"
    fi

    # Recursively call the function to create the next folder
    create_folders $((depth + 1)) "$new_folder"
}

# Start creating folders from the current directory
create_folders 0 "$(pwd)"

# Final messages after script execution
echo "Folders and hidden files created successfully!"
echo "To reveal the reversed flag, use the following command:"
echo "find . -name '.flag_*' | sort | xargs cat | tr -d '\n'"
echo "To reveal the story, use the following command:"
echo "find . -name '.story_*' | sort | xargs cat | tr ' ' '_'"

