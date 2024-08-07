#!/bin/bash
# Script location $HOME/OpenOrangeStorm/img-config/set-printer-model.sh

# Define the flag file path
FLAG_FILE="/boot/.OpenOrangeStorm.txt"

# Function to select an option
select_option() {
    local -n ref=$1
    echo -e "$2"
    select opt in "${@:3}"; do
        if [[ -n $opt ]]; then
            ref=$opt
            break
        else
            echo -e "Invalid option, please try again."
        fi
    done
}

# Headless operation checks
if [ "$auto_yes" = "true" ]; then
    if [ -z "$model_key" ]; then
        echo "Headless mode for giga requires --motor_current and --pcb_version."
        exit 1
    fi
else
    # Interactive mode for model selection
    echo "Please select your printer model:"
    select _ in "GIGA"; do
        case $REPLY in
            1) model_key="GIGA";;
            *) echo "Invalid selection. Please try again."; continue;;
        esac
        break
    done
fi

# Define FLAG_LINE before generating configuration
if [[ "$model_key" = "GIGA" ]]; then
    FLAG_LINE="${model_key}-v3.0"
else
    return 0 
fi

# Capitalize the 1st and 3rd letters of the model_key
FLAG_LINE=$(echo "$FLAG_LINE" | sed -E 's/^(n)(4)(.)(.*)/\U\1\2\3\E\4/')

echo "DEBUG: FLAG_LINE is $FLAG_LINE"

# Function to update the flag file
update_flag_file() {
    local flag_value=$1
    # Remove existing lines starting with OS (case-insensitive), then add the new line
    sudo sed -i '/^GIGA/I d' "$FLAG_FILE"
    echo "$flag_value" | sudo tee -a "$FLAG_FILE" > /dev/null
}

update_flag_file "$FLAG_LINE"

# Check the contents of the FLAG_FILE
#echo "DEBUG: Contents of $FLAG_FILE"
#sudo cat "$FLAG_FILE"
sync
exit 0
