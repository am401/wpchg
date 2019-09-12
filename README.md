# wpchg
This is a bash script written to be run in the background on Linux systems and utilize cron jobs to persistantly change a user's background. The initial setup script creates a daemon to run in the background, ensuring that all elements for the change to be present: the crontab line, the image file to be utilized and the script that will change the background. If any of these are missing, the script will either re-download the necessary item or recreate it.

# disclaimer
This script was written as a project during RHCSA class. Due to the daemon running in the background, creating new instances of script and such if it detects it being deleted, it could be utilized as malware. No responsibility is taken if its purpose or functionality is edited in this way.

# usage
Download the script and edit the file and website variables. The website variable should contain an absolute path pointing to the image, that wget will be able to utilize ie: http://mysite.com/images/ while the file variable should contain the image filename ie wallpaper.jpg
wget will put the variables together to form http://mysite.com/images/wallpaper.jpg and the rest of the script will then use the file variable to make changes to the background.

This script works on Gnome and has been tested on various Linux flavors. You can also edit the crontab information to set the changes to meet your needs. It has been tested with a variety and ie 0 2 * * * and */2 * * * *
