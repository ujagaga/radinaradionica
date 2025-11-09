# Radina radionica

This is a collection of projects running on my own server and instructions on how to build and maintain them. 
The projects running are all in the `~/Applications` folder of the server home folder and are started as a service.
The whole `~/Applications` folder is periodically backed up on a flash drive, so restoring should be as simple as copying the old data to the new OS home folder and running the `install.sh` script of each app.
There is also a `~/.ssh` folder backed up to the USB flash. It is needed for a read-only access to github repository of each app.
A Cloudflared tunnel enables external access to this server.

## Setting up

