#!/bin/bash

sudo pacman -S fcitx5-im fcitx5-rime



# Check if the current session is X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "X11 session detected. Proceeding to configure environment variables for fcitx5."

    # 1. Define the path string (tilde will be expanded by the shell)
    # In shell, ~ is expanded unless quoted. We can use $HOME for clarity.
    file_path_str="${HOME}/.config/environment.d/envvars.conf"

    # 2. Expand the tilde (already handled by using ${HOME} or letting shell expand ~)
    # expanded_path is essentially file_path_str when used correctly in shell

    # 3. Get the directory part of the path
    # The dirname command can do this
    directory=$(dirname "$file_path_str")

    # 4. Create the directory (and any parent directories) if it doesn't exist
    #    mkdir -p does this (p for parents, no error if exists)
    mkdir -p "$directory"
    if [ $? -ne 0 ]; then
        echo "Error: Could not create directory $directory"
        exit 1
    fi

    # 5. Now open the file for appending (it will be created if it doesn't exist)
    #    In shell, this is done with '>>' redirection.
    #    We use a "here document" (<<EOF ... EOF) for multi-line input.
    #    Quoting "EOF" prevents variable expansion and command substitution within the here document,
    #    which is good practice here, though not strictly necessary for this specific content.
    cat << 'EOF' >> "$file_path_str"
# fcitx
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS=@im=fcitx5
# fcitx
EOF
    # The Python script had an explicit newline at the end of the string.
    # The here document naturally ends with a newline if the content does,
    # or if there's a newline before the closing EOF.
    # The provided Python content has a newline embedded before the closing triple quote.

    if [ $? -eq 0 ]; then
        echo "Successfully wrote to $file_path_str"
    else
        echo "Error: Failed to write to $file_path_str"
        exit 1
    fi

elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "Wayland session detected. Doing nothing as requested."
else
    echo "Session type is neither X11 nor Wayland (XDG_SESSION_TYPE: '$XDG_SESSION_TYPE'). Doing nothing."
fi














# Script to switch virtual keyboard in KDE Plasma 6
# Usage:
#   ./switch_vk.sh fcitx5   # To enable Fcitx 5
#   ./switch_vk.sh none     # To disable virtual keyboard (set to None)

# --- Configuration ---
# The .desktop file for Fcitx 5. This is usually the correct name.
# If Fcitx 5 was installed differently, this might need to be adjusted.
# You can typically find this in /usr/share/applications/
# and it should contain: X-KDE-Wayland-VirtualKeyboard=true
FCITX5_DESKTOP_FILE="org.fcitx.Fcitx5.desktop"

# KWin configuration file
KWINRC_FILE="$HOME/.config/kwinrc" # kwriteconfig6 defaults to this if --file is kwinrc

# --- Functions ---

# Function to set the virtual keyboard
set_virtual_keyboard() {
    local input_method_value="fcitx5"
    local display_name="fcitx5"

    echo "Attempting to set virtual keyboard to: $display_name"

    # Use kwriteconfig6 to change the setting in kwinrc
    # The --file argument for kwinrc can be just "kwinrc" and it will resolve to ~/.config/kwinrc
    kwriteconfig6 --file kwinrc --group Wayland --key InputMethod "$input_method_value"

    if [ $? -eq 0 ]; then
        echo "Successfully updated kwinrc."
        echo "Applying changes to KWin..."
        # Tell KWin to reconfigure
        qdbus6 org.kde.KWin /KWin reconfigure
        if [ $? -eq 0 ]; then
            echo "KWin reconfigure command sent. Virtual keyboard set to: $display_name"
            echo "If the change is not immediate, a logout/login might be required for full effect."
        else
            echo "Error: Failed to send reconfigure command to KWin via qdbus."
            echo "The kwinrc file was updated, but you may need to logout/login or restart KWin manually."
        fi
    else
        echo "Error: Failed to update kwinrc using kwriteconfig6."
    fi
}

# --- Main Script Logic ---


# Process the argument
set_virtual_keyboard "$FCITX5_DESKTOP_FILE" "Fcitx 5 ($FCITX5_DESKTOP_FILE)"


git clone https://github.com/iDvel/rime-ice.git Rime --depth 1
cd Rime
cp -r ./* ~/.local/share/fcitx5/rime/

echo "please reboot your computer to apply"



exit 0


