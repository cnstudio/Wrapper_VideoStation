#!/bin/bash

version="SCPT_1.2"
# Changes:
# SCPT_1.0: Initial release of the automatic installer script for DMS 7.X. (Deprecated migrated to SCPT_1.1)
# SCPT_1.1: To avoid discrepancies and possible deletion of original binaries when there is a previously installed wrapper, an analyzer of other installations has been added. (Deprecated migrated to SCPT_1.2)
# SCPT_1.2: Added a configurator tool for select the codecs

###############################
# VARIABLES
###############################

dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="install"
dependencias=("VideoStation" "ffmpeg" "CodecPack" "MediaServer")
RED="\u001b[31m"
BLUE="\u001b[36m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
supported_versions=("7.0" "7.1")
injector="1-12.3.3"
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_bin_path=/var/packages/CodecPack/target/pack/bin
all_files=("$ms_libsynovte_file.orig" "vs_libsynovte_file.orig" "$cp_bin_path/ffmpeg41.orig")


###############################
# FUNCIONES
###############################

function log() {
  echo -e  "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2"
}
function info() {
  log "${BLUE}INFO" "${YELLOW}$1"
}
function error() {
  log "${RED}ERROR" "${RED}$1"
}

function restart_packages() {
  if [[ -d $cp_bin_path ]]; then
    info "${YELLOW}Restarting CodecPack..."
    synopkg restart CodecPack
  fi

  info "${YELLOW}Restarting VideoStation..."
  synopkg restart VideoStation
  
  info "${YELLOW}Restarting MediaServer..."
  synopkg restart MediaServer
}

function check_dependencias() {
  for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/$dependencia" ]]; then
      error "Missing $dependencia package, please install it and re-run the patcher setup."
      exit 1
    fi
  done
}
function welcome() {
  info "FFMPEG WRAPPER INSTALLER version: $version"

  welcome=$(curl -s -L "$repo_url/main/welcome.txt")
  if [ "${#welcome}" -ge 1 ]; then
    echo ""
    echo -e "${GREEN}	$welcome"
    echo ""
  fi
}
function check_version() {
    DSM=$1
    DELIMITER=$2
    VALUE=$3
    LIST_WHITESPACES=`echo $DSM | tr "$DELIMITER" " "`
    for xdsm in $LIST_WHITESPACES; do
        if [ "$xdsm" = "$VALUE" ]; then
            return 0
        fi
    done
    return 1
}

################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
  info "${BLUE}==================== Installation: Start ===================="

for losorig in "$all_files"; do
if [[ -f "$losorig" ]]; then
        info "${YELLOW}Actually you have a old patch applied in your system, please uninstall older wrapper first."
        while true; do
        read -p "Do you wish to uninstall this old wrapper? " yn
        case $yn in
        [Yy]* ) uninstall_old; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
        esac
        done
else
  
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig."
#    	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig
	  info "${YELLOW}Creating the esqueleton of the ffmpeg41"
#	touch ${cp_bin_path}/ffmpeg41 
	  info "${YELLOW}Injection of the ffmpeg41 wrapper."
#	wget $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper."
#	chmod 755 ${cp_bin_path}/ffmpeg41
	info "${GREEN}Installed correctly the wrapper41 in $cp_bin_path"
	
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig."
#	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig"
#	chown VideoStation:VideoStation $vs_libsynovte_file.orig
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
#	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file
	info "${GREEN}Modified correctly the file $vs_libsynovte_file"
	
	info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig."
#	cp -n $ms_libsynovte_file $ms_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig"
#	chown MediaServer:MediaServer $ms_libsynovte_file.orig
#	chmod 644 $ms_libsynovte_file.orig
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
#	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file
	info "${GREEN}Modified correctly the file $ms_libsynovte_file"
	
#	restart_packages
	
fi
done

  echo ""
  info "${BLUE}==================== Installation: Complete ===================="

}

function uninstall_old() {
  info "${BLUE}==================== Uninstallation of old wrappers in the system: Start ===================="

  info "${YELLOW}Restoring VideoStation´s libsynovte.so"
#  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  info "${YELLOW}Restoring MediaServer´s libsynovte.so"
#  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"

#  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
#    info "${YELLOW}Restoring VideoStation's $filename"
#    mv -T -f "$filename" "${filename::-5}"
#  done

#  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
#      mv -T -f "$filename" "${filename::-5}"
#  done

  echo ""
  info "${BLUE}==================== Uninstallation of old wrappers in the system: Complete ===================="
  info "${BLUE}====================Continuing with installation of the new wrapper...===================="
  
  install
}

function uninstall() {
  info "${BLUE}==================== Uninstallation: Start ===================="

  info "${YELLOW}Restoring VideoStation´s libsynovte.so"
#  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  info "${YELLOW}Restoring MediaServer´s libsynovte.so"
#  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"

#  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
#      mv -T -f "$filename" "${filename::-5}"
#    done


 # restart_packages

  echo ""
  info "${BLUE}==================== Uninstallation: Complete ===================="
}

function configurator() {
   info "${BLUE}==================== Configuration: Start ===================="
   info "${BLUE}Actually you have two audio streams, first MP3 2.0 256kbps and second 5.1 AAC 512kbps."
   info "${YELLOW}REMEMBER: If you change the order you will have ALWAYS AAC 5.1 512kbps in first audio stream in VideoStation and DLNA and some devices not compatibles with 5.1 neigther multi audio streams like Chromecast won't work"
   echo -e "${GREEN}A) FIRST STREAM= AAC 5.1 512kbps, SECOND STREAM= MP3 2.0 256kbps" 
   echo -e "${GREEN}B) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps" 
	while true; do
        read -p "Do you wish to change the order of these audio stream in the actual wrapper? " ab
        case $ab in
        [Aa] ) echo "LLAMADA A FUNCION"; break;;
        [Bb] ) exit;;
        * ) echo "Please answer with the correct option writing: A or B.";;
        esac
        done
   
   info "${BLUE}==================== Configuration: Complete ===================="
}

################################
# EJECUCIÓN
################################
while getopts s: flag; do
  case "${flag}" in
    s) setup=${OPTARG};;
    *) echo "usage: $0 [-s install|uninstall|config]" >&2; exit 1;;
  esac
done

# start
clear
echo -e "${BLUE}====================FFMPEG WRAPPER INSTALLER FOR DSM 7.X by Dark Nebular.===================="
echo -e "${BLUE}====================This wrapper installer is only avalaible for "${supported_versions[@]}" only===================="
echo ""
welcome

check_dependencias

if check_version "$dsm_version" " " 7.0; then
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}7.0 is supported for this installer and the installer will tuned for your DSM"
   cp_bin_path=/var/packages/CodecPack/target/bin
   injector="0-12.2.2"
   info "${BLUE}7.0 is using this path: $cp_bin_path"
   info "${BLUE}7.0 is using this injector: $injector"
fi
if check_version "$dsm_version" " " 7.1; then
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}7.1 is supported for this installer and the installer will tuned for your DSM"
   cp_bin_path=/var/packages/CodecPack/target/pack/bin
   injector="1-12.3.3"
   info "${BLUE}7.1 is using this path: $cp_bin_path"
   info "${BLUE}7.1 is using this injector: $injector"
else
 error "Your DSM Version $dsm_version is NOT supported using this installer. Please use the manual procedure."
 exit 1
fi




case "$setup" in
  install) install;;
  uninstall) uninstall;;
  config) configurator;;
esac