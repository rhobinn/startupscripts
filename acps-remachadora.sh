echo ""
echo "Select an option number:"
echo "1) download code"
echo "2) install docker compose + configure locales"
echo "3) add USB permissions"
echo "4) ALL"



function download_from_repository {

    export GITHUB_USER=rhobinn
    export GITHUB_CREATOR=rhobinn
    export GITHUB_REPOSITORY=acps-remachadora
    echo ""
    echo "please copy GITHUB_TOKEN: ???"
    echo ""

    # create token: https://github.com/settings/tokens?type=beta
    read GITHUB_TOKEN

    #set directories
    sudo rm -rf  ~/Programs/${GITHUB_REPOSITORY}
    mkdir -p ~/Programs
    sudo chmod a+rwx ~/Programs
    cd ~/Programs

    #clone repository
    git clone https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_CREATOR}/${GITHUB_REPOSITORY}.git


    #add env vars
    echo ""
    echo "paste env variables (press Intro twice to finish reading): ???"
    echo ""

    sudo rm -f ~/Programs/${GITHUB_REPOSITORY}/.env || true
    while read -r ENV_VARS  && [ "$ENV_VARS" != "" ]
    do
        echo $ENV_VARS >> ~/Programs/${GITHUB_REPOSITORY}/.env
    done

}


function new_rpi_preparation {

    #to stop warning on raspbian devices when doing apt stuff
    sudo dpkg-reconfigure locales

    #install pip
    sudo apt update
    sudo apt upgrade
    sudo apt install pip
    sudo pip3 install --upgrade pip

    #install python & pip
    sudo apt-get install -y libffi-dev libssl-dev
    sudo apt install -y python3-dev
    sudo apt-get install -y python3 python3-pip

    #install docker
    curl -fsSL test.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    sudo usermod -aG docker ${USER}
    groups ${USER}

    #install docker compose
    sudo pip3 install docker-compose
    #sudo apt install docker-compose


    #enable launching of docker compose when starting system
    sudo systemctl enable docker

    sudo reboot

    #test docker
    docker run hello-world
}

function usb_preparation {
    #add udevrules for usb devices
    echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", SYMLINK+="ttyUSBrem"' | sudo tee /etc/udev/rules.d/88-usb-serial.rules > /dev/null

    #add user to dialout group
    sudo usermod -aG dialout ${USER}

}

read USER_OPTION

case $USER_OPTION in

  1)
    download_from_repository
    ;;

  2)
    new_rpi_preparation
    ;;

  3)
    usb_preparation
    ;;

  4)
    download_from_repository
    new_rpi_preparation
    usb_preparation
    ;;
  

  *)
    echo ""
    echo -n "Unknown option"
    echo ""
    ;;
esac
