#!/bin/bash
# Multi-Library Search with Title/Author Filtering

# 1. Select the Library
echo "--- 1. SELECT LIBRARY ---"
PS3="Enter library number: "
select FILE in goodreads_*.json "Exit"; do
    if [ "$FILE" == "Exit" ]; then exit 0;
    elif [ -f "$FILE" ]; then break;
    else echo "Invalid selection."; fi
done

# 2. Select Search Mode
echo -e "\n--- 2. SELECT SEARCH MODE ---"
PS3="Search by (1-2): "
select MODE in "Title" "Author"; do
    case $MODE in
        "Title")  QUERY_FIELD=".title"; break ;;
        "Author") QUERY_FIELD=".author"; break ;;
        *) echo "Invalid choice." ;;
    esac
done

# 3. Launch fzf with Targeted Preview
# We only pipe the chosen field to fzf for a cleaner search experience
jq -r ".[] | $QUERY_FIELD" "$FILE" | sort | uniq | \
    fzf --header "Searching $MODE in $FILE" \
        --prompt "Filter $MODE > " \
        --border \
        --height 70% \
        --layout=reverse \
        --preview "jq -r --arg q {1} --arg f \"${QUERY_FIELD#.}\" '.[] | select(.[\$f] == \$q)' \"$FILE\"" \
        --preview-window=right:50%:wrap

