#!/bin/bash

if test -t 1; then
    ncolors=$(which tput > /dev/null && tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

function console_log() {
    echo "${white}[$(date)]${normal} $1"
}

function console_error() {
    echo "${bold}${red}[$(date)] $1${normal}"
}

function console_success() {
    echo "${white}[$(date)]${bold}${green} $1${normal}"
}

function section_title() {
    echo "${bold}${green}================================================================================${normal}"
    echo
    echo -e "\t${bold}${green}$1${normal}"
    echo
    echo "${bold}${green}================================================================================${normal}"
    echo
}

function if_error_exit() {
    return_code=$1
    action=$2
    if [ "$return_code" -ne "0" ]; then
        console_error "${action} is failed."
        exit 1
    fi
    console_success "Done."
}

function if_error_return() {
    return_code=$1
    action=$2
    if [ "$return_code" -ne "0" ]; then
        console_error "${action} is failed."
        return 1
    fi
    console_success "Done."
    return 0
}

function apt_update() {
    console_log "apt-get update started."
    sudo apt-get -qq update
    if_error_return $? "apt-get update"
    return $?
}

function apt_upgrade() {
    console_log "apt-get upgrade started."
    sudo apt-get -qq -y upgrade 
    if_error_return $? "apt-get upgrade"
    return $?
}

function apt_install() {
    console_log "Install: $1"
    sudo apt-get -y --no-install-recommends -qq install $1
    if_error_return $? "Install $1"
    return $?
}

function fn01_build_essential() {
    fn01_fail_count=0
    section_title "[Job 1] Install build essentials."
    apt_update
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_upgrade
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install make
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install gcc
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install g++
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install pcscd
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install pcsc-tools
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install dvb-tools
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install libccid
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install libdvbv5-dev
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install libpcsclite-dev
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install build-essential
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install automake
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install pkg-config
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install wget
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install git
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install vim
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install unzip
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install cmake
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install ffmpeg
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install raspberrypi-kernel
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install raspberrypi-kernel-headers
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install dkms
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install ca-certificates
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install curl
    fn01_fail_count=$((fn01_fail_count + $?))
    apt_install gnupg
    fn01_fail_count=$((fn01_fail_count + $?))
    if [ $fn01_fail_count -ne 0 ]; then
        console_error "Install build essentials is failed."
        exit 1
    fi
    section_title "[Job 1] Install build essentials. Done."
    console_log "${bold}${yellow}The Raspberry Pi will be reboot after 10 sec.${normal}"
    sleep 10s
    sudo shutdown -r now
}

function fn02_build_fw_w3u4() {
    section_title "[Job 2] Build and Install PLEX PX-W3U4 firmware."
    user_pwd=`pwd`
    cd ~

    console_log "Clone repository: nns779/px4_drv"
    git clone -q https://github.com/nns779/px4_drv.git
    if_error_exit $? "Clone repository"

    console_log "Change directory: px4_drv/fwtool"
    cd px4_drv/fwtool
    if_error_exit $? "Change directory"

    console_log "Build fwtool."
    make
    if_error_exit $? "Build"

    console_log "Download device driver from plex-net.co.jp."
    wget http://plex-net.co.jp/download/pxw3u4v1.4.zip -O pxw3u4v1.4.zip
    if_error_exit $? "Download"

    console_log "Unzip device driver."
    unzip -oj pxw3u4v1.4.zip pxw3u4v1/x64/PXW3U4.sys
    if_error_exit $? "Unzip"

    console_log "Make firmware."
    ./fwtool PXW3U4.sys it930x-firmware_pxw3u4.bin
    if_error_exit $? "Make firmware"

    console_log "Publish firmware."
    sudo mkdir -p /lib/firmware
    sudo mv it930x-firmware_pxw3u4.bin /lib/firmware/it930x-firmware.bin
    if_error_exit $? "Publish"

    console_log "Clean..."
    rm ./pxw3u4v1.4.zip ./PXW3U4.sys
    if_error_exit $? "Clean"

    console_log "Change directory: px4_drv"
    cd ../
    if_error_exit $? "Change directory"
    
    console_log "Build custom driver."
    sudo cp -a ./ /usr/src/px4_drv-0.2.1
    sudo dkms add px4_drv/0.2.1
    if_error_exit $? "Build"
    
    console_log "Install custom driver."
    sudo dkms install px4_drv/0.2.1
    if_error_exit $? "Install"
    
    console_log "Load px4_drv module."
    sudo modprobe px4_drv
    if_error_exit $? "Load module"

    console_log "Check /boot/cmdline.txt"
    cat /boot/cmdline.txt | grep coherent_pool=4M
    if [ $? -ne 0 ]; then
        console_log "${yellow}Append `coherent_pool=4M` to /boot/cmdline.txt${normal}"
        echo -n `cat /boot/cmdline.txt` coherent_pool=4M > ./cmdline.txt
        sudo cp ./cmdline.txt /boot/cmdline.txt
        if_error_exit $? "Append"
        rm ./cmdline.txt
    else
        console_success "OK."
    fi

    console_log "Check /etc/modules"
    cat /etc/modules | grep px4_drv
    if [ "$?" -ne "0" ]; then
        console_log "${yellow}Append `px4_drv` to /etc/modules${normal}"
        cat /etc/modules > ./modules
        echo px4_drv >> ./modules
        sudo cp ./modules /etc/modules
        if_error_exit $? "Append"
        rm ./modules
    else
        console_success "OK."
    fi
    cd $user_pwd

    section_title "[Job 2] Build and Install PLEX PX-W3U4 firmware. Done!"
}

function fn03_setup_rec_tools() {
    section_title "[Job 3] Setup Recording tools."
    user_pwd=`pwd`
    cd ~

    console_log "Download libarib25 from github.com."
    wget --no-check-certificate https://github.com/stz2012/libarib25/archive/master.zip -O ./libarib25.zip
    if_error_exit $? "Download"

    console_log "Unzip libarib25."
    unzip -o libarib25.zip
    if_error_exit $? "Unzip"

    console_log "Change directory: libarib25-master"
    cd libarib25-master
    if_error_exit $? "Change directory"

    console_log "Cmake libarib25"
    cmake .
    if_error_exit $? "Cmake libarib25"

    console_log "Make libarib25"
    make
    if_error_exit $? "Make libarib25"

    console_log "Install libarib25"
    sudo make install
    if_error_exit $? "Install libarib25"

    console_log "Change directory: ~"
    cd ~
    if_error_exit $? "Change directory"
    
    console_log "Download recpt1 from github.com."
    wget --no-check-certificate https://github.com/stz2012/recpt1/archive/master.zip -O ./recpt1.zip
    if_error_exit $? "Download"

    console_log "Unzip recpt1."
    unzip -o recpt1.zip
    if_error_exit $? "Unzip"

    console_log "Change directory: recpt1-master/recpt1"
    cd recpt1-master/recpt1
    if_error_exit $? "Change directory"
    
    console_log "Exec autogen."
    ./autogen.sh
    if_error_exit $? "Exec autogen"
    
    console_log "Configure recpt1."
    ./configure --enable-b25
    if_error_exit $? "Configure recpt1"

    console_log "Make recpt1."
    make
    if_error_exit $? "Make recpt1"

    console_log "Install recpt1."
    sudo make install
    if_error_exit $? "Install recpt1"

    console_log "Change directory: ~"
    cd ~
    if_error_exit $? "Change directory"

    console_log "Clean..."
    rm ./libarib25.zip
    if_error_exit $? "Remove libarib25.zip"
    rm -rf libarib25-master
    if_error_exit $? "Remove libarib25-master"
    rm ./recpt1.zip
    if_error_exit $? "Remove recpt1.zip"
    rm -rf recpt1-master
    if_error_exit $? "Remove recpt1-master"
    cd $user_pwd

    section_title "[Job 3] Setup Recording tools. Done!"
}

function fn04_setup_mirakurun_epgstation() {
    section_title "[Job 4] Setup Mirakurun and EPGStation."
    user_pwd=`pwd`
    cd ~

    console_log "Make directory /etc/apt/keyrings"
    sudo mkdir -p /etc/apt/keyrings
    if_error_exit "Make directory"

    console_log "Save key to nodesource.gpg"
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    if_error_exit "Save key to nodesource.gpg"

    console_log "Append Node.js v16.x repository"
    NODE_MAJOR=16
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    if_error_exit "Append"

    apt_update
    apt_install nodejs=16.20.2-1nodesource1

    console_log "Install pm2"
    sudo npm install pm2 --location=global
    if_error_exit "Install pm2"

    console_log "Startup pm2"
    sudo pm2 startup
    if_error_exit "Startup pm2"

    console_log "Install mirakurun@3.8.1"
    sudo npm install mirakurun@3.8.1 --location=global --production
    if_error_exit "Install mirakurun@3.8.1"

    console_log "Init mirakurun"
    sudo mirakurun init
    if_error_exit "Init mirakurun"

    console_log "Append Node.js v18.x repository"
    NODE_MAJOR=18
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    if_error_exit "Append"
    
    apt_update
    apt_install nodejs

    console_log "Install mirakurun@latest"
    sudo npm install mirakurun --location=global --production
    if_error_exit "Install mirakurun@latest"

    console_log "Restart mirkurun"
    sudo mirakurun restart
    if_error_exit "Restart mirkurun"

    console_log "Change directory: ~"
    cd ~
    if_error_exit "Change directory"

    console_log "Clone repository: l3tnun/EPGStation"
    git clone https://github.com/l3tnun/EPGStation.git
    if_error_exit "Clone repository: l3tnun/EPGStation"

    console_log "Change directory: EPGStation"
    cd EPGStation
    if_error_exit "Change directory"

    console_log "Build EPGStation"
    npm run all-install
    npm run build
    if_error_exit "Build EPGStation"

    console_log "Copy config"
    cp config/config.yml.template config/config.yml
    cp config/operatorLogConfig.sample.yml config/operatorLogConfig.yml
    cp config/epgUpdaterLogConfig.sample.yml config/epgUpdaterLogConfig.yml
    cp config/serviceLogConfig.sample.yml config/serviceLogConfig.yml
    cp config/enc.js.template config/enc.js
    if_error_exit "Copy config"

    console_log "Change ffmpeg path in config.uml"
    sed -i -e "s/usr\/local\/bin/usr\/bin/g" ~/EPGStation/config/config.yml
    if_error_exit "Change ffmpeg path"

    console_log "Append EPGStation to pm2 list"
    sudo pm2 start dist/index.js --name "epgstation"
    if_error_exit "Append EPGStation to pm2 list"
    
    console_log "Save pm2"
    sudo pm2 save
    if_error_exit "Save pm2"

    console_log "${bold}========================================${normal}"
    console_log "${bold}Node.js    : ${cyan}$(nodejs -v)${normal}"
    console_log "${bold}npm        : ${cyan}$(npm -v)${normal}"
    console_log "${bold}pm2        : ${cyan}$(pm2 -V)${normal}"
    console_log "${bold}mirakurun  : ${cyan}$(sudo mirakurun version | grep mirakurun | cut -d '@' -f 2)${normal}"
    console_log "${bold}EPGStation : ${cyan}$(curl -s http://localhost:8888/api/version | cut -d '"' -f 4)${normal}"
    console_log "${bold}========================================${normal}"
    cd $user_pwd

    section_title "[Job 4] Setup Mirakurun and EPGStation. Done!"
}

function fn00_interactive_menu() {
    section_title "Why not try recording anime easily with Raspberry Pi!\n\t\tCould you select a job?"
    select choice in ">>>>>> Exec init (Job1)" ">>>>>> Exec install (Job2, Job3)" "[Job1] Install build essentials." "[Job2] Build Firmware PX-W3U4." "[Job3] Setup Recording tools." "[Job4] Setup Mirakurun and EPGStation." "       Exit."
    do
        case $choice in
            ">>>>>> Exec init (Job1)")
                fn01_build_essential
                break
                ;;
            ">>>>>> Exec install (Job2, Job3, Job4)")
                fn02_build_fw_w3u4
                fn03_setup_rec_tools
                fn04_setup_mirakurun_epgstation
                break
                ;;
            "[Job1] Install build essentials.")
                fn01_build_essential
                break
                ;;
            "[Job2] Build Firmware PX-W3U4.")
                fn02_build_fw_w3u4
                ;;
            "[Job3] Setup Recording tools.")
                fn03_setup_rec_tools
                ;;
            "[Job4] Setup Mirakurun and EPGStation.")
                fn04_setup_mirakurun_epgstation
                ;;
            "       Exit.")
                exit 0
                ;;
            *)
                echo "${red}Invalid selection.${normal}"
                ;;
        esac
    done
}

case $1 in
    init)
        fn01_build_essential
        ;;
    install)
        fn02_build_fw_w3u4
        fn03_setup_rec_tools
        fn04_setup_mirakurun_epgstation
        ;;
    job1)
        fn01_build_essential
        ;;
    job2)
        fn02_build_fw_w3u4
        ;;
    job3)
        fn03_setup_rec_tools
        ;;
    job4)
        fn04_setup_mirakurun_epgstation
        ;;
    *)
        fn00_interactive_menu
        ;;
esac
