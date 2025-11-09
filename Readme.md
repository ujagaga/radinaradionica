# Radina radionica

This is a collection of projects running on my own server and instructions on how to build and maintain them. 
The projects running are all in the `~/Applications` folder of the server home folder and are started as a service.
The whole `~/Applications` folder is periodically backed up on a flash drive, so restoring should be as simple as copying the old data to the new OS home folder and running the `install.sh` script of each app.
There is also a `~/.ssh` folder backed up to the USB flash. It is needed for a read-only access to github repository of each app.
A Cloudflared tunnel enables external access to this server.

## Setting up

1. Select a computer to run as a server. I am using Raspberry Pi 4, but any linux SBC will do.
2. Install any Debian based OS. I preffer Armbian for armbi-config utility.
3. Prepare a USB Flash and label it "Backup". Plug it in the server computer
4. SSH to the server.
5. Clone the backup repository and install: 

    git clone git@github.com:ujagaga/radinaradionica.git
    cd radinaradionica/backup/
    ./install.sh

The backup script will now run at noon and midnight every day.
6. Install Cloudflared to manage the tunneling:

    # Add cloudflare gpg key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

    # Add this repo to your apt repositories
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

    # install cloudflared
    sudo apt-get update && sudo apt-get install cloudflared

7. Clone and install other needed services in Applications folder.

## Restoring

In case the main storage gets corrupted, follow these steps to repair:

1. Replace it with a new storage with a fresh OS.
2. install the Cloudflared tunnel
3. Make sure the backup USB flash is plugged in
4. navigate to it and run: `backup/usb_restore.sh`
5. This will restore all data in the Applications folder. You just need to browse to each folder and run the correcponding `install.sh`

In case the USB flash gets corrupted, just replace it with a new one, labeled `Backup` and let the backup service copy the necessary files.
