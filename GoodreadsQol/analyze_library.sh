#!/bin/bash

# 1. Look for all JSON files starting with 'goodreads'
echo "--- AVAILABLE LIBRARIES ---"
PS3="Please select the JSON file to analyze (1-N): "

# The 'select' command creates an interactive menu from the file list
select FILE in goodreads_*.json "Exit"; do
    if [ "$FILE" == "Exit" ]; then
        echo "Exiting..."
        exit 0
    elif [ -f "$FILE" ]; then
        echo "Selected: $FILE"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

# --- 2. Author Statistics (Specific to chosen file) ---
echo "--- LIBRARY SUMMARY: $FILE ---"
TOTAL_BOOKS=$(jq '. | length' "$FILE")
UNIQUE_AUTHORS=$(jq '[.[] | .author] | unique | length' "$FILE")

echo "Total Books: $TOTAL_BOOKS"
echo "Unique Authors: $UNIQUE_AUTHORS"
echo "Diversity Ratio: $(echo "scale=2; $UNIQUE_AUTHORS / $TOTAL_BOOKS" | bc)"
echo "-----------------------"

# --- 3. Top 10 Most Frequent Authors ---
echo "TOP 10 AUTHORS IN $FILE:"
jq -r '.[] | .author' "$FILE" | sort | uniq -c | sort -nr | head -n 10
echo "-----------------------"

# --- 4. Interactive Search (Piped to fzf if available) ---
if command -v fzf >/dev/null 2>&1; then
    echo "Launching Interactive Search for $FILE..."
    jq -r '.[] | "\(.author) | \(.title)"' "$FILE" | fzf --header "Searching: $FILE"
else
    echo "Usage for manual search: jq '.[] | select((.title|ascii_downcase|contains(\"term\")) or (.author|ascii_downcase|contains(\"term\")))' \"$FILE\""
fi

