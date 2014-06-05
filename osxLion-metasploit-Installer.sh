#!/bin/bash
#
# Script to automate the installation of Metasploit Framework (MSF) on OS X Lion and Mountain Lion.
#
# Jackie Singh, 2012 (jackie@jackiesingh.com) 
# Permission to copy and modify is granted under the WTFPL license (http://www.wtfpl.net/about/) 
# Last revised 14 March 2013
#
# You should run through each step sequentially. Please update the database password below on line 458 prior 
# to running this script. Additionally, your machine must have a route to the internet as a prerequisite to 
# running this script. If you experience difficulties, you may create a log file by running this script like 
# this: ./script.sh 2>&1 | tee script.log
#
# Make sure to set a DB password on line 443 first.
#

clear 

function press_enter {
	echo ""
	read -p "Hit [Return] to continue"

}
function exit_status_cont {
        export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo ""
	echo "[OK] That seems to have gone well. Press 0 to continue."
	echo ""
        else
	echo ""
	echo ""
        echo "[ERROR] Something may have gone wrong with that last thing we did. Press 0 to continue or CTRL + C to exit."
	echo ""
        fi
}

function exit_status
{
        export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo ""
	echo "[OK] That seems to have gone well. Moving along."
	echo ""
        else
	echo ""
	echo ""
        echo "[ERROR] Something may have gone wrong with that last thing we did. You may wish to exit."
	echo ""
        fi
}

function xcode_error
{
        pkgutil --pkgs | grep Xcode; export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo "[OK] Xcode seems to be installed. Continuing..."
        else
	echo ""
        echo "[ERROR] Are you missing Xcode? Install it prior to running this script, please."
	echo "XCode can be installed from the MAS https://itunes.apple.com/us/app/xcode/id497799835"
	echo ""
	exit
        fi
}

function xcode_clt_error
{
        pkgutil --pkgs | grep CLTools ; export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo "[OK] Xcode Command Line Tools seems to be installed. Continuing..."
        else
	echo ""
        echo "[ERROR] Are you missing Xcode's Command Line Tools? Install this package prior to running this script, please."
	echo "You can use xcode-select --install to install xcode CLT.  If that fails, download from the developer site"
	echo ""
	exit
        fi
}

function java_error
{
        pkgutil --pkgs | grep JavaTool; export OUT=$?
        if [ $OUT -eq 0 ]; then
	echo ""
	echo "[OK] Java seems to be installed. Continuing..."
        else
	echo ""
        echo "[ERROR] Are you missing Java? Install it prior to running this script, please."
	echo ""
	exit
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

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 1 of 12]"
echo "Checking for Prerequisites..."
echo "--------------------------------------------------------------------------"

echo ""
echo "Checking for Xcode..."
echo ""
xcode_error;

echo ""
echo "Checking for Xcode Command Line Tools..."
echo ""
xcode_clt_error;

echo ""
echo "Checking for Java..."
echo ""
java_error;

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 2 of 12]"
echo "Install Homebrew"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" ; brew doctor ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 3 of 12]"
echo "Updating paths for homebrew binaries"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to add /usr/local/bin and /usr/local/sbin to your .bash_profile."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) echo PATH=/usr/local/bin:/usr/local/sbin:$PATH >> ~/.bash_profile ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 4 of 12]"
echo "Install nmap"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install nmap using homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) brew install nmap ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 5 of 12]"
echo "Update Homebrew"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to update the formula and homebrew."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) brew update ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 6 of 12]"
echo "Install GNU GCC"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install GNU GCC 4.2 after compiling from source." 
echo "This may take an hour or more depending on your processor."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) brew tap homebrew/dupes; brew install apple-gcc42 ; exit_status_cont ;;
        esac
done

GCC_VER=`gcc -dumpversion`
echo ""
echo "[INFO] You are running GCC Version $GCC_VER"
echo ""

echo "[STEP 6a]"
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

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 7 of 12]"
echo "Install Ruby"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install Ruby + dependencies."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) brew install readline openssl rbenv ruby-build ; export CC=clang ; export RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline`" ; rbenv install 2.0.0-p0 ; rbenv rehash ; rbenv global 2.0.0-p0 ; exit_status_cont ;;
        esac
done

echo ""	
RUBY_VER=`ruby -v`
echo ""
echo "[INFO] You are running $RUBY_VER"
echo ""

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 8 of 12]"
echo "Install PostgreSQL"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install PostgreSQL."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) brew install postgresql --without-ossp-uuid ; exit_status_cont ;;
        esac
done

POSTGRES_VER=`postgres -V`
echo ""
echo "[INFO] You are running $POSTGRES_VER"

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 8a]"
echo "First-time database initialization"
echo ""
echo "Enter 0 to skip doing this and continue."
echo "Enter 1 to initialize the database for the first time."
echo "--------------------------------------------------------------------------"
selection1=
until [ "$selection1" = "0" ]; do
echo ""
echo ""
read selection1
case $selection1 in
                1 ) initdb /usr/local/var/postgres ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 8b]"
echo "Modifying configuration to ask Postgres to load on login"
echo ""
echo "Enter 0 to skip doing this and continue."
echo "Enter 1 to ask Postgres to load on login."
echo "--------------------------------------------------------------------------"
selection2=
until [ "$selection2" = "0" ]; do
echo ""
echo ""
read selection2
case $selection2 in
                1 ) mkdir -p ~/Library/LaunchAgents ;
		    POSTGRES_VER_NUM=`echo "$POSTGRES_VER" | sed 's/[[:alpha:]|(|)|[:space:]]//g' | awk -F- '{print $1}'` ;
		      cp /usr/local/Cellar/postgresql/$POSTGRES_VER_NUM/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/ ;
		      launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist ;
		      exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 8c]"
echo "Creating new database user named msf"
echo ""
echo "Enter 0 to skip doing this and continue."
echo "Enter 1 to create msf user."
echo "Set the same password here as you set in the script before you ran it."
echo "--------------------------------------------------------------------------"
selection3=
until [ "$selection3" = "0" ]; do
echo ""
echo ""
read selection3
case $selection3 in
                1 ) createuser msf -P -h localhost ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 8d]"
echo "Creating database for use with Metasploit"
echo ""
echo "Enter 0 to skip doing this and continue."
echo "Enter 1 to set up database for use with MSF and set new user msf as owner."
echo "--------------------------------------------------------------------------"
selection4=
until [ "$selection4" = "0" ]; do
echo ""
echo ""
read selection4
case $selection4 in
                1 ) createdb -O msf msf -h localhost ; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 9 of 12]"
echo "Install needed Ruby gems for MSF"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to install needed gems, including sqlite3. Need sudo access here."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) gem install pg; exit_status ; sudo gem install sqlite3; exit_status ; gem install msgpack; exit_status ; gem install hpricot ; sudo gem update --system ; exit_status_cont ;;
        esac
done

echo ""
echo "Updating some configs related to vncviewer..."
press_enter
echo ""
echo '#!/usr/bin/env bash'  >> /usr/local/bin/vncviewer 
echo open vnc://\$1 >> /usr/local/bin/vncviewer
chmod +x /usr/local/bin/vncviewer
echo "Done."

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 10 of 12]"
echo "Get MSF using git via Github"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to git clone MSF. This may take a while... Please be patient."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/; git clone git://github.com/rapid7/metasploit-framework.git; exit_status_cont ;;
        esac
done

echo ""
echo "--------------------------------------------------------------------------"
echo "[STEP 11 of 12]"
echo "Symlinking some stuff..."
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo "Enter 1 to complete needed symlinks for MSF's proper operation."
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/metasploit-framework; for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF; done ; exit_status_cont ;;
        esac
done

echo ""
echo "Making some symlinks for the proper operation of Armitage..."
press_enter;
echo ""
ln -s /usr/local/share/metasploit-framework/armitage /usr/local/bin/armitage
echo ""
echo "Need to use sudo for a moment, please. Totally legit."
sudo chmod go+w /etc/profile
sudo echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/database.yml >> /etc/profile
sudo chmod go-w /etc/profile
echo ""
echo "Done."

echo ""
echo "Creating database.yml file..."
#
# Please set below the user/password you will set for the Metasploit database, and ensure there is a space after the colon.
# The other values are OK as default unless you've got a special configuration elsewhere.
#
echo 'production:
   adapter: postgresql
   database: msf
   username: msf
   password: test
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
echo "--------------------------------------------------------------------------"
echo "[STEP 12 of 12]"
echo "Installing pcaprub library"
echo ""
echo "Enter 0 to skip this step and continue to the next."
echo ""
echo "Enter 1 to install the pcaprub library for modules used to craft packets."  
echo "[NOTE] Warnings shouldn't be a big deal here. Safe to ignore."
echo ""
echo "--------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
                1 ) cd /usr/local/share/metasploit-framework/external/pcaprub ; ruby extconf.rb && make && make install ; exit_status_cont ;;
        esac
done

echo "----------------------------------------------------------------------------------------------------------------------"
echo "[FINAL STEP]"
echo "A reboot is highly suggested."
echo ""
echo "Enter 0 to end this script without doing anything."
echo "Enter 1 to [sudo] start msfconsole"
echo "Enter 2 to [sudo] reboot this machine."
echo "----------------------------------------------------------------------------------------------------------------------"
selection=
until [ "$selection" = "0" ]; do
echo ""
echo ""
read selection
case $selection in
               1 ) sudo -E msfconsole;
		;;
		2 ) echo "After your machine comes back up, start msf by typing [sudo -E msfconsole]"; press_enter; sudo reboot now;
        esac
done

trap 0
exit 0
