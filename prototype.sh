# Please do not use this file. It is only intended for testing new features and can potentially damage the system.
#!/bin/bash
# E-Paper-Calendar software installer for the raspberry pi
# Version: 1.5 (Early Februrary 2019)
# Well tested and confirmed on 3rd Feb 2019

# Copyright by aceisace

echo -e "\e[1mPlease select an option from below:"
echo -e "\e[97mEnter \e[91m1 \e[97m to install/update the E-Paper software"
echo -e "\e[97mEnter \e[91m2 \e[97m to uninstall the E-Paper software"
echo -e "\e[1mNote: Updating will back up just the settings.py file."
echo -e "\e[97mConfirm your selection with [ENTER]"
read -r -p 'Waiting for input...  ' option

if [ "$option" != 1 ] && [ "$option" != 2 ]; then
    echo "invalid number, aborting now"
    exit
fi

if [ -z "$option" ]; then
    echo "You didn't enter anything, aborting now."
    exit
fi


if [ "$option" = 2 ]; then
    echo "Removing the E-Paper software now..."
    pip3 uninstall Pillow && sudo pip3 uninstall Pillow && sudo pip3 uninstall pyowm && sudo pip3 uninstall ics && pip3 uninstall pyowm && pip3 uninstall ics && sudo apt-get remove --purge supervisor -y && sudo apt-get clean && sudo apt-get autoremove -y && sudo rm -r /home/pi/E-Paper-Master/
fi


if [ "$option" = 1 ]; then
    echo "Checking if the software is installed"
    if [ -e /home/pi/E-Paper-Master/Calendar/settings.py ]
    then
        echo "Found an E-Paper settings file."
        sleep 2
	echo "Backing up the current settings file in the home directory."
	sleep 2
	cp /home/pi/E-Paper-Master/Calendar/settings.py /home/pi/settings-old.py
	echo "renaming the old E-Paper software folder"
	sleep 2
	cp -r /home/pi/E-Paper-Master /home/pi/E-Paper-Master-old
	echo "Updating now..."
        # Getting input to see which E-Paper version is currently being used.
    fi
    echo -e "\e[1mWhich version of the E-Paper display are you using?"
    echo -e "\e[97mEnter \e[91m2 \e[97m if you are using the 2-Colour E-Paper"
    echo -e "\e[97mEnter \e[91m3 \e[97m if you are using the 3-Colour E-Paper"
    echo -e "\e[97mconfirm your selection with [ENTER]"
    read -r -p 'Please type in the number now:  ' digit

    if [ -z "$digit" ]; then
        echo "You didn't enter anything."
        echo "Aborting now."
        exit
    fi

    if [ "$digit" != 2 ] && [ "$digit" != 3 ]; then
        echo "invalid number, only 2 or 3 can be accepted."
        echo "Aborting now."
        exit
    fi

    if [ "$digit" = 2 ] || [ "$digit" = 3 ]; then
        echo ""
        echo -e "\e[1;36m"Your input was accepted"\e[0m"
        echo -e "\e[1;36m"The installer will finish the rest now. You can enjoy a break in the meanwhile."\e[0m"
        echo ""
    fi

    # Updating and upgrading the system, without taking too much space
    echo -e "\e[1;36m"Running apt-get update and apt-get dist-upgrade for you..."\e[0m"
    echo -e "\e[1;36m"This will take a while, sometimes up to 30 mins"\e[0m"
    sudo apt-get update && sudo apt-get dist-upgrade -y
    echo -e "\e[1;36m"System successfully updated and upgraded!"\e[0m"
    echo ""

    # Installing a few packages which are missing on Raspbian Stretch Lite
    echo -e "\e[1;36m"Installing a few packages that are missing on Raspbian Stretch Lite..."\e[0m"
    sudo apt-get install python3-pip python-rpi.gpio-dbgsym python3-rpi.gpio python-rpi.gpio python3-rpi.gpio-dbgsym python3-spidev git libopenjp2-7-dev libtiff5 -y
    pip3 install Pillow==5.3.0
    sudo pip3 install Pillow==5.3.0
    echo ""
fin

    # Running apt-get clean and apt-get autoremove
    echo -e "\e[1;36m"Cleaning a bit of mess to free up some space..."\e[0m"
    sudo apt-get clean && sudo apt-get autoremove -y
    echo ""

    # Installing packages required by the main script
    echo -e "\e[1;36m"Installing a few required packages for the E-Paper Software"\e[0m"
    sudo pip3 install pyowm
    sudo pip3 install ics
    pip3 install pyowm
    pip3 install ics
    echo ""

    echo -e "\e[1;36m"Installing the E-Paper-Calendar Software for your display"\e[0m"
    cd
    git clone https://github.com/aceisace/E-Paper-Calendar-with-iCal-sync-and-live-weather
    mkdir E-Paper-Master
    cd E-Paper-Calendar-with-iCal-sync-and-live-weather
    cp -r Calendar /home/pi/E-Paper-Master/
    cp README.md /home/pi/E-Paper-Master/
    cp LICENSE /home/pi/E-Paper-Master/
    cp -r .git /home/pi/E-Paper-Master/
    cd
    sudo rm -r E-Paper-Calendar-with-iCal-sync-and-live-weather

    # Using this part for the 2-colour E-Paper version
    if [ "$digit" = 2 ]; then
        # edit the settings file for the 2-colour display option
        sed -i 's/display_colours = "bwr"/display_colours = "bw"/' /home/pi/E-Paper-Master/Calendar/settings.py
        
        # add a short info
        cat > /home/pi/E-Paper-Master/Info.txt << EOF
    This document contains a short info of the E-Paper-Calendar software version

    Version: 2-Colour E-Paper-version
    Installer version: 1.5 (Early February 2019)
    configuration file: /home/pi/E-Paper-Master/Calendar/settings.py
    If the time was set correctly, you installed this software on:
EOF
        echo "$(date)" >> /home/pi/E-Paper-Master/Info.txt
        echo ""
    fi

    # Using this part for the 3-colour E-Paper version
    if [ "$digit" = 3 ]; then
        # add a short info
        cat > /home/pi/E-Paper-Master/Info.txt << EOF
    This document contains a short info of the version

    Version: 3-Colour E-Paper-version
    Installer version: 1.5 (Early February 2019)
    configuration file: /home/pi/E-Paper-Master/Calendar/settings.py
    If the time was set correctly, you installed this software on:
EOF
        echo "$(date)" >> /home/pi/E-Paper-Master/Info.txt
        echo ""
    fi

    # Setting up supervisor
    echo -e "\e[1;36m"Setting up the script to start at boot..."\e[0m"
    sudo apt-get install supervisor -y

    sudo bash -c 'cat > /etc/supervisor/conf.d/E-Paper.conf' << EOF
    [program:E-Paper]
    command = sudo /usr/bin/python3.5 /home/pi/E-Paper-Master/Calendar/E-Paper.py
    stdout_logfile = /home/pi/E-Paper-Master/E-Paper.log
    stdout_logfile_maxbytes = 1MB
    stderr_logfile = /home/pi/E-Paper-Master/E-Paper-err.log
    stderr_logfile_maxbytes = 1MB
EOF

    sudo service supervisor start E-Paper
    echo ""

    # Final words
    echo -e "\e[1;36m"The install was successful"\e[0m"
    echo -e "\e[1;36m"The programm will now start at every boot."\e[0m"

    echo -e "\e[1;31m"Please enter your details in the file 'settings.py'."\e[0m"
    echo -e "\e[1;31m"If this file is not modified, the programm will not start"\e[0m"

    echo -e "\e[1;36m"To modify the settings file, enter:"\e[0m"
    echo -e "\e[1;36m"nano /home/pi/E-Paper-Master/Calendar/settings.py"\e[0m"

fi
