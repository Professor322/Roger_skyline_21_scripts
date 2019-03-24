CYAN='\033[0;36m'  
GRAY='\033[0;37m'
GREEN='\033[0;32m'

mkdir -p DEPLOY_REP
cd deploy_rep || exit 0
git init
git remote add deploy ssh://vlegros@192.168.21.88:2225/home/vlegros/.git
git pull deploy master
printf "${CYAN}working directory is ${GREEN}DEPLOY_REP${GRAY}\n"
