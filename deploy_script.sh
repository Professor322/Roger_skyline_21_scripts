GREEN='\033[0;32m'      
GRAY='\033[0;37m'       
CYAN='\033[0;36m' 
#!/bin/bash

# Call this file with `bash ./project-create.sh project-name [service-name]`
# - project-name is mandatory
# - service-name is optional

# This will creates 4 directories and a git `post-receive` hook.
# The 4 directories are:
# - $GIT: a git repo
# - $TMP: a temporary directory for deployment
# - $WWW: a directory for the actual production files
# - $ENV: a directory for the env variables

# When you push your code to the git repo,
# the `post-receive` hook will deploy the code
# in the $TMP directory, then copy it to $WWW.

TMP="/home/vlegros/tmp/"
WWW="/usr/share/nginx/html/"
GIT="/home/vlegros/.git/"

# Create a directory for the git repository
sudo mkdir -p "$GIT"
cd "$GIT" || exit

# Init the repo as an empty git repository
sudo git init --bare

# Define group recursively to "users", on the directories
sudo chgrp -R users .

# Define permissions recursively, on the sub-directories
# g = group, + add rights, r = read, w = write, X = directories only
# . = curent directory as a reference
sudo chmod -R g+rwX .

# Sets the setgid bit on all the directories
# https://www.gnu.org/software/coreutils/manual/html_node/Directory-Setuid-and-Setgid.html
sudo find . -type d -exec chmod g+s '{}' +

# Make the directory a shared repo
sudo git config core.sharedRepository group

cd hooks || exit

# create a post-receive file
sudo tee post-receive <<EOF
#!/bin/bash
# The production directory
WWW="/usr/share/nginx/html/"
# A temporary directory for deployment
TMP="/home/vlegros/tmp/"
# The Git rep
GIT="/home/vlegros/.git/"
mkdir -p $TMP
git --work-tree=$TMP --git-dir=$GIT checkout -f
cd $TMP || exit
rm -rf $WWW\*
mv ./* $WWW
sudo systemctl restart nginx
EOF

# make it executable
sudo chmod +x post-receive
print "${GREEN}local repository is created${GREY}\n"
