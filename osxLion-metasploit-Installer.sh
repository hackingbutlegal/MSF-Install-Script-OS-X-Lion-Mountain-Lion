#!/bin/bash
#
# Script to automate the installation of Metasploit Framework (MSF) on OS X Lion and Mountain Lion.
#
# Copyright (C) 2012 Jackie Singh - All Rights Reserved
# Permission to copy and modify is granted under the foo license
# Last revised 10/5/2012
#
# Please update the database password below on line 371 prior to running this script.
# Additionally, your machine must have a route to the internet as a prerequisite to running this script.
# If you experience difficulties, you may create a log file by running this script like this: ./script.sh 2>&1 | tee script.log
#

clear

function press_enter
{
	echo ""
	read -p "Press [Return] to continue"
}

function exit_status
{
        export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo ""
	echo "[OK] That seems to have gone well. Press 0 to continue."
        else
	echo ""
	echo ""
        echo "[ERROR] Something may have gone wrong with that last thing we did. Check log for details."
		echo ""
        fi
}

echo ""
echo ""
echo "--------------------------------------------------------------------------"
echo "Installing Metasploit Framework on this (Lion or Mountain Lion) OS X box"
echo "--------------------------------------------------------------------------"
echo "(Ctrl + C to exit at any time)"
echo ""

press_enter;
clear

echo ""
echo "[STEP 1 of 12]"
echo "Check for Java/Install"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to test for Java's presence on your machine/install if necessary."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
		1 ) java ; exit_status ;;
	esac
done

clear

echo ""
echo "[STEP 2 of 12]"
echo "Install Homebrew"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)" ; exit_status ;;
        esac
done

clear

echo ""
echo "[STEP 3 of 12]"
echo "Updating paths for homebrew binaries"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to add /usr/local/bin and /usr/local/sbin to your .bash_profile."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) echo PATH=/usr/local/bin:/usr/local/sbin:$PATH >> ~/.bash_profile ; exit_status ;;
        esac
done

clear

echo ""
echo "[STEP 4 of 12]"
echo "Install nmap"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install nmap using homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) brew install nmap ; exit_status ;;
        esac
done

clear

echo ""
echo "[STEP 5 of 12]"
echo "Update Homebrew"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to update the formula and homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) brew update ; exit_status ;;
        esac
done

clear

echo ""
echo "[STEP 6 of 12]"
echo "Install GNU GCC"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install GNU GCC 4.2 after compiling from source." 
echo "This may take an hour or more depending on your processor."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) brew tap homebrew/dupes; brew install apple-gcc42 ; exit_status ;;
        esac
done

clear

GCC_VER=`gcc -dumpversion`
echo ""
echo "[INFO] You are running GCC Version $GCC_VER"
echo ""

echo "Now setting environment variables for color and compilation flags..."
press_enter;
echo ""
echo export CLICOLOR=1 >> ~/.bash_profile
echo export LSCOLORS=GxFxCxDxBxegedabagaced >> ~/.bash_profile
echo "" >> ~/.bash_profile
echo export ARCHFLAGS=\"-arch x86_64\" >> ~/.bash_profile
echo export CC=/usr/local/bin/gcc-4.2 >> ~/.bash_profile
source ~/.bash_profile
echo "Done."

clear

echo ""
echo "[STEP 7 of 12]"
echo ""
echo "Install Ruby"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install Ruby."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) brew install ruby ; exit_status ;;
        esac
done

clear

RUBY_VER=`ruby -v`
echo ""
echo "[INFO] You are running $RUBY_VER"
echo ""

echo "[STEP 8 of 12]"
echo ""
echo "Install PostgreSQL"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install PostgreSQL."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) brew install postgresql --without-ossp-uuid ; exit_status ;;
        esac
done

clear

POSTGRES_VER=`postgres -V`
echo ""
echo "[INFO] You are running $POSTGRES_VER"
echo ""

echo ""
echo "First time database initialization..."
press_enter;
echo ""
initdb /usr/local/var/postgres
echo "Done."

echo ""
echo "Asking Postgres to load on login..." 
echo "If this errors out for any reason, check homebrew output after postgres install for proper instructions."
press_enter;
echo ""
mkdir -p ~/Library/LaunchAgents
cp /usr/local/Cellar/postgresql/9.2.1/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
echo "Done."

echo ""
echo "Creating user for use with Metasploit... You need to set the same password here as you set in this script before you ran it :-)"
press_enter
echo ""
createuser msf -P -h localhost
echo "Done."

echo ""
echo "Creating database for use with Metasploit and setting user msf as the owner..."
press_enter
echo ""
createdb -O msf msf -h localhost
echo "Done."

clear

echo ""
echo "[STEP 9 of 12]"
echo ""
echo "Install needed Ruby gems for MSF"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install the needed gems, including sqlite3."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) gem install pg sqlite3 msgpack hpricot ; exit_status ;;
        esac
done

clear

echo ""
echo "Updating some things related to vncviewer..."
press_enter
echo ""
echo '#!/usr/bin/env bash'  >> /usr/local/bin/vncviewer 
echo open vnc://\$1 >> /usr/local/bin/vncviewer
chmod +x /usr/local/bin/vncviewer
echo "Done."

echo ""
echo "[STEP 10 of 12]"
echo ""
echo "Get MSF using Subversion"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to check out MSF. This may take a while... Please be patient."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/; svn --trust-server-cert --non-interactive co https://www.metasploit.com/svn/framework3/trunk metasploit-framework; exit_status ;;
        esac
done

clear

echo "[STEP 11 of 12]"
echo ""
echo "Symlinking some stuff..."
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to complete needed symlinks for MSF's proper operation."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/metasploit-framework; for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF; done ; exit_status ;;
        esac
done

clear

echo ""
echo "Symlinking Armitage…"
press_enter;
echo ""
ln -s /usr/local/share/metasploit-framework/armitage /usr/local/bin/armitage
echo ""
echo "Need to use sudo for a moment, please. Totally legit."
sudo chmod go+w /etc/profile
sudo echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/database.yml >> /etc/profile
echo ""
echo "Done."

echo ""
echo "Performing miscellaneous tasks..."
#
#
# Please set below the password you will set for the Metasploit user, using a space after the colon.
#
#
echo 'production:
   adapter: postgresql
   database: msf
   username: msf
   password:
   host: 127.0.0.1
   port: 5432 
   pool: 75
   timeout: 5' > /usr/local/share/metasploit-framework/database.yml

echo ""
echo "Loading variable from profile configs..."
source /etc/profile
source ~/.bash_profile
echo "Done."

echo ""
echo "[STEP 12 of 12]"
echo ""
echo "Installing pcaprub library"
echo ""
echo "--------------------------------------------------------------------------"
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install the pcaprub library for modules used to craft packets."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo -n "Enter your selection:  "
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/metasploit-framework/external/pcaprub ; ruby extconf.rb && make && make install ; exit_status ;;
        esac
done

clear

echo ""
echo "The installation is presumably finished."
echo "To use Armitage and other modules in Metasploit, you will need to use root. The next time you launch the application, try:"
echo "------------------"
echo "sudo -E armitage"
echo "or"
echo "sudo -E msfconsole"
echo "------------------"
echo ""
echo "Now attempting to start msfconsole as your current user for first time to initialize schema with current user and not root."
echo ""
press_enter

msfconsole

trap 0
exit 0
