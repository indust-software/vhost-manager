#!/bin/bash
clear;

# Color variables
#
# Terminal color variables
# ----------------------------------------------------------------------------
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
BLUE=`tput setaf 4`
CYAN=`tput setaf 6`
NC=`tput sgr0`


# Default settings
#
# Change below variables to modify default script behaviour
# ----------------------------------------------------------------------------
vhost_name="mywebsite.loc";
cert_file=${HOME}"/.ssl/server/server.crt"
cert_key=${HOME}"/.ssl/server/server.key"
root_path=${HOME}"/www"
enableSSL="true"

echo "";
echo "";
echo "";
echo "${BLUE}";
echo " _    ____  __           __                                      __            ";
echo "| |  / / / / /___  _____/ /_   ____ ____  ____  ___  _________ _/ /_____  _____";
echo "| | / / /_/ / __ \/ ___/ __/  / __ \`/ _ \/ __ \/ _ \/ ___/ __ \`/ __/ __ \/ ___/";
echo "| |/ / __  / /_/ (__  ) /_   / /_/ /  __/ / / /  __/ /  / /_/ / /_/ /_/ / /    ";
echo "|___/_/ /_/\____/____/\__/   \__, /\___/_/ /_/\___/_/   \__,_/\__/\____/_/     ";
echo "                            /____/                                             ";

echo "";
echo "(c) Indust 2015. All Rights Reserved.";
echo "${NC}";
echo "";


# ------------------------------------------------------------------------------
# Remove existing host functionality
# -----------------------------------------------------------------------------

removeVhost() {
  read -p "${NC}Please enter virtual host name:${NC} " name_answer

  echo "${GREEN}Removing nginx sites${NC}"
  rm /etc/nginx/sites-enabled/$name_answer
  rm /etc/nginx/sites-available/$name_answer

  echo "${GREEN}Removing hosts entry${NC}"
  sed -i '/'$name_answer'/d' /etc/hosts

  echo "${GREEN}Restarting nginx${NC}"
  service nginx restart

  echo "${GREEN}All done. Please remove webisite files manualy.${NC}"
  echo ""

  exit 1;
}

read -p "Generate or remove (G/r)?: " choice
case "$choice" in
  r|R ) removeVhost;;
esac


# ------------------------------------------------------------------------------
# Collect new virtual host options
# ------------------------------------------------------------------------------


echo "";
read -p "${NC}Please enter virtual host name ($vhost_name):${NC} " name_answer

if [ "$name_answer" != "" ]
  then vhost_name=$name_answer;
fi

echo "${GREEN}Your new vhost name is:${CYAN} $vhost_name${NC}"
echo "";

useSSL() {
  printf "${GREEN}SSL will be enabled on port 443\nUse certificate from:${CYAN} ${cert_file}${GREEN}\nUse certificate key from:${CYAN} ${cert_key}${NC}\n";
}

disableSSL() {
  enableSSL="false"
  echo "${RED}SSL disabled${NC}";
}

read -p "Do You want to use SSL also (Y/n)?: " choice
case "$choice" in
  y|Y ) useSSL;;
  n|N ) disableSSL;;
  * ) useSSL;;
esac

echo "";

read -p "${NC}Enter website root path (${root_path}/${vhost_name}):${NC} " root_answer

if [ "$root_answer" != "" ]
  then root_path=$root_answer;
  else root_path=$root_path/$vhost_name;
fi

echo "${GREEN}Your website path is:${CYAN} $root_path${NC}"
echo "";

# ------------------------------------------------------------------------------
# Generate virtual host
# ------------------------------------------------------------------------------


echo "Creating new virtual host...";
echo "";
echo "";

echo "${YELLOW}Creating Nginx configuration file in: ${CYAN}/etc/nginx/sites-available/$vhost_name ${NC}";

vhost_file=/etc/nginx/sites-available/$vhost_name;

# Copy temlates files and create vhost configuration file
cat vhost_80.tpl > $vhost_file;
if [ "$enableSSL" = "true" ]
  then cat vhost_443.tpl >> $vhost_file;
fi

# Replace variables in vhost configuration file
sed -i "s|{{root_path}}|$root_path|g" $vhost_file
sed -i "s|{{vhost_name}}|$vhost_name|g" $vhost_file
sed -i "s|{{cert_key}}|$cert_key|g" $vhost_file
sed -i "s|{{cert_file}}|$cert_file|g" $vhost_file

echo "${YELLOW}Making new virtual host active${NC}";
ln -s $vhost_file /etc/nginx/sites-enabled/

echo "${YELLOW}Creating website directory: ${CYAN}$root_path${NC}";
mkdir $root_path

echo "${YELLOW}Restarting Nginx server${NC}";
service nginx restart

echo "${YELLOW}Adding entry into ${CYAN}/etc/hosts${YELLOW} file${NC}";
sed -i '/'$vhost_name'/d' /etc/hosts
printf "\n127.0.0.1\t"$vhost_name >> /etc/hosts

echo "";
echo "";
echo "${GREEN}Everything is complete. Please visit your website url: ${NC}";
echo "${CYAN}http://"$vhost_name"${NC}";
if [ "$enableSSL" = "true" ]
  then echo "${CYAN}https://"$vhost_name"${NC}";
fi
echo "";
echo "";
