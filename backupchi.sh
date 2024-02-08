#!/bin/bash

# Ensure script is executable
chmod +x "$0"

if [ "$(id -u)" != "0" ]; then
    echo "You must run this script as root. Exiting..."
    exit 1
else
    echo "User is root. Proceeding with the script..."

    # Update the server and install zip
    if [ -x "$(command -v apt-get)" ]; then
        apt-get update
    elif [ -x "$(command -v dnf)" ]; then
        dnf update -y
    elif [ -x "$(command -v yum)" ]; then
        yum update -y
    else
        echo "Unsupported package manager. Exiting..."
        exit 1
    fi

    if [ -x "$(command -v apt-get)" ]; then
        apt-get install -y zip
    elif [ -x "$(command -v dnf)" ]; then
        dnf install -y zip
    elif [ -x "$(command -v yum)" ]; then
        yum install -y zip
    else
        echo "Unsupported package manager. Exiting..."
        exit 1
    fi

# echo $'\e[36m'" __ )               |                         |     _) 
 __ \   _` |   __|  |  /  |   |  __ \    __|  __ \   | 
 |   | (   |  (       <   |   |  |   |  (     | | |  | 
____/ \__._| \___| _|\_\ \__._|  .__/  \___| _| |_| _| 
                                _|                     "$'\e[0m'


    # Menu for user selection
    echo -e "\e[36mCreated By Masoud Gb Special Thanks Hamid Router\e[0m"
echo $'\e[35m'"Backupchi Script v0.1"$'\e[0m'
    echo "Select an option:"
    echo $'\e[32m'"1. Local server"$'\e[0m'
    echo $'\e[32m'"2. Backup server"$'\e[0m'
    echo $'\e[32m'"3. Uninstall"$'\e[0m'
    echo $'\e[32m'"4. Exit"$'\e[0m'

    read -p "Enter your choice (1-4): " choice

    case $choice in
    1)
    echo "Setting up a local server..."

    # Install nginx
    read -p $'\e[32m'"Do you want to install nginx? (y/n): "$'\e[0m' install_nginx
    if [ "$install_nginx" == "y" ]; then
        if [ -x "$(command -v apt-get)" ]; then
            apt-get install -y nginx
        elif [ -x "$(command -v dnf)" ]; then
            dnf install -y nginx
        elif [ -x "$(command -v yum)" ]; then
            yum install -y nginx
        else
            echo $'\e[31m'"Unsupported package manager. Exiting..."$'\e[0m'
            exit 1
        fi

        # Ask for backup directory path
        read -p $'\e[32m'"Enter the backup directory path (default: /etc/x-ui): "$'\e[0m' backup_path
        backup_path="${backup_path:-/etc/x-ui}"
        echo "Backup directory path set to: $backup_path"

        # Ask for backup filename
        read -p $'\e[32m'"Enter the backup filename (default: backup): "$'\e[0m' backup_filename
        backup_filename="${backup_filename:-backup}"

        # Ask for zip password
        read -s -p $'\e[32m'"Enter password for the zip file: "$'\e[0m' zip_password
        echo

        # Confirm zip password
        read -s -p $'\e[32m'"Confirm password: "$'\e[0m' confirm_zip_password
        echo

        # Check if passwords match
        if [ "$zip_password" != "$confirm_zip_password" ]; then
            echo $'\e[31m'"Passwords do not match. Exiting..."$'\e[0m'
            exit 1
        fi

        echo $'\e[32m'"Zip password set successfully."$'\e[0m'

        # Ask for backup interval
        echo "Choose backup interval:"
        echo $'\e[32m'"1. Every few minutes"$'\e[0m'
        echo $'\e[32m'"2. Every few hours"$'\e[0m'
        echo $'\e[32m'"3. Every few days"$'\e[0m'
        echo $'\e[32m'"4. Every few weeks"$'\e[0m'
        read -p "Enter your choice (1-4): " backup_interval_choice

        case $backup_interval_choice in
            1)
                echo "Enter the minutes: "
                read -p $'\e[32m'"Enter the interval value: "$'\e[0m' backup_interval_value
                cron_interval="*/$backup_interval_value * * * *"
                ;;
            2)
                read -p "Enter the hours: " backup_interval_value
                cron_interval="0 */$backup_interval_value * * *"
                ;;
            3)
                read -p "Enter the days: " backup_interval_value
                cron_interval="0 0 */$backup_interval_value * *"
                ;;
            4)
                read -p "Enter the weeks: " backup_interval_value
                cron_interval="0 0 * * */$backup_interval_value"
                ;;
            *)
                echo $'\e[31m'"Invalid choice. Exiting..."$'\e[0m'
                exit 1
                ;;
        esac

        # Create cron job for backup
        cron_command="cd $backup_path && zip -r -P $zip_password $backup_filename.zip * && mv $backup_filename.zip /var/www/html/ && chmod 755 /var/www/html/$backup_filename.zip"
        cron_job="$cron_interval $cron_command"
        (crontab -l ; echo "$cron_job") | crontab -

        echo $'\e[32m'"Cron job for backup scheduled successfully."$'\e[0m'

        # Display backup password and success message with download link
        server_ip=$(hostname -I | awk '{print $1}')
        echo $'\e[32m'"Installation steps completed successfully."$'\e[0m'
        echo $'\e[33m'"Backup password: $zip_password"$'\e[0m'
        echo $'\e[33m'"Your download link: http://$server_ip/$backup_filename.zip"$'\e[0m'

        # Ask the user if they want to send the backup file to Telegram
        read -p $'\e[32m'"Do you want to send the backup file to Telegram? (y/n): "$'\e[0m' send_to_telegram

        if [ "$send_to_telegram" == "y" ]; then
            # Ask for Telegram bot token in green
            read -p $'\e[32m'"Enter your Telegram bot token: "$'\e[0m' telegram_token

            # Ask for Telegram chat ID in green
            read -p $'\e[32m'"Enter your Telegram chat ID: "$'\e[0m' telegram_chat_id
        fi

        # Create cron job for backup and sending to Telegram
        cron_command="cd $backup_path && zip -r -P $zip_password $backup_filename.zip * && mv $backup_filename.zip /var/www/html/ && chmod 755 /var/www/html/$backup_filename.zip"

        if [ "$send_to_telegram" == "y" ]; then
            # Add Telegram send command to cron job
            telegram_cron_command="curl -s -F chat_id=$telegram_chat_id -F document=@/var/www/html/$backup_filename.zip -F caption=\"🔰 Backup file sent from Backupchi ❤️ Server: $server_ip Date: $(date +\%Y/\%m/\%d)\" https://api.telegram.org/bot$telegram_token/sendDocument"
            cron_command="$cron_command && $telegram_cron_command"
        fi

        # Use user-defined backup interval
        cron_job="* * * * * $cron_command"
        (crontab -l ; echo "$cron_job") | crontab -

        echo $'\e[32m'"The backup file was sent successfully. Check out the Telegram bot"$'\e[0m'
        exit 0
    else
        echo "Skipping nginx installation."
    fi
    ;;

    2)
    echo "Setting up a backup server..."

    # Ask the user for the backup file link
    read -p $'\e[32m'"Enter the link to the backup file (e.g., http://example.com/backup.zip): "$'\e[0m' backup_link

    # Extract the filename from the backup link
    backup_filename=$(basename "$backup_link")

    # Set the default backup destination
    default_backup_destination="/root/backupchi"
    backup_destination=""

    # Ask the user if they want to use the default backup directory
    read -p $'\e[32m'"Do you want to use the default backup directory ($default_backup_destination)? (y/n): "$'\e[0m' use_default_directory
    if [ "$use_default_directory" == "y" ] || [ -z "$use_default_directory" ]; then
        backup_destination="$default_backup_destination"
    else
        # Ask the user for the custom backup file destination path
        read -p $'\e[32m'"Enter the backup file destination path: "$'\e[0m' custom_backup_destination
        # Update the backup destination if the user provided a custom path
        backup_destination="$custom_backup_destination"
    fi

    # Create the backup directory if it doesn't exist
    mkdir -p "$backup_destination"

    # Ask the user for the backup interval
    echo "Choose backup interval:"
    echo $'\e[32m'"1. Every few minutes"$'\e[0m'
    echo $'\e[32m'"2. Every few hours"$'\e[0m'
    echo $'\e[32m'"3. Every few days"$'\e[0m'
    echo $'\e[32m'"4. Every few weeks"$'\e[0m'
    read -p "Enter your choice (1-4): " backup_interval_choice

    case $backup_interval_choice in
        1)
            echo "Enter the minutes: "
            read -p $'\e[32m'"Enter the interval value: "$'\e[0m' backup_interval_value
            cron_interval="*/$backup_interval_value * * * *"
            ;;
        2)
            read -p "Enter the hours: " backup_interval_value
            cron_interval="0 */$backup_interval_value * * *"
            ;;
        3)
            read -p "Enter the days: " backup_interval_value
            cron_interval="0 0 */$backup_interval_value * *"
            ;;
        4)
            read -p "Enter the weeks: " backup_interval_value
            cron_interval="0 0 * * */$backup_interval_value"
            ;;
        *)
            echo $'\e[31m'"Invalid choice. Exiting..."$'\e[0m'
            exit 1
            ;;
    esac

    # Create cron job for backup server
    cron_command="wget -O $backup_destination/$backup_filename $backup_link"
    cron_job="$cron_interval $cron_command"
    (crontab -l ; echo "$cron_job") | crontab -

    # Ask the user if they want to schedule another backup link
    read -p $'\e[32m'"Do you want to schedule another backup link? (y/n): "$'\e[0m' schedule_another
    if [ "$schedule_another" == "y" ]; then
        # Repeat the process for scheduling another backup link
        echo "Setting up another backup server..."
        # ...

        # Continue with other configurations...

        echo $'\e[32m'"Backup server setup completed successfully."$'\e[0m'
    else
        echo $'\e[32m'"Backup server setup completed successfully."$'\e[0m'
    fi
   ;;

  3)
echo "Uninstalling script. Exiting..."

# Check user's confirmation before proceeding to uninstall
echo -n $'\e[32m'"Are you sure you want to uninstall script ? (y/n): "$'\e[0m'
read confirm_uninstall

# Check user's confirmation
if [ "$confirm_uninstall" == "y" ]; then
    # Check user's confirmation before removing the backup directory
    echo -n $'\e[32m'"Do you want to remove the backup folder ? (y/n): "$'\e[0m'
    read confirm_backup_removal

    # Check user's confirmation
    if [ "$confirm_backup_removal" == "y" ]; then
        # Remove backup directory
        rm -rf "/root/backupchi"
        echo "Backup directory removed."
    else
        echo "Backup directory not removed."
    fi
fi

# Remove only cron jobs with .zip extension
(crontab -l | grep -v ".zip" ) | crontab -

echo "Uninstall completed successfully."
    exit 0
    ;;

  4)
            echo "Exiting..."
            echo -e "\e[32mGoodbye! Hope to see you again.\e[0m"
    exit 0
    ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
fi
