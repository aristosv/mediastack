# mediastack
Deluge - Jackett - Plex - Portainer - Radarr - Sonarr
```
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/aristosv/mediastack-raspberrypi/master/mediastack)
```
Run the command above on a Raspbery Pi running Raspbian Stretch Lite.

It will install Deluge / Jackett / Plex / Portainer / Radarr / Sonarr, in a containerized environment.

After the installation, this is how you can access all the web apps:

```
Name: deluge
Usage: download manager
URL: http://<your_pi_ip_here>:8112
Pass: deluge
```
```
Name: jackett
Usage: api torrent tracker
URL: http://<your_pi_ip_here>:9117
```
```
Name: plex
Usage: plex media server
URL: http://<your_pi_ip_here>:32400/web
```
```
Name: portainer
Usage: docker container management
URL: http://<your_pi_ip_here>:9000
```
```
Name: radarr
Usage: download movies
URL: http://<your_pi_ip_here>:7878
```
```
Name: sonarr
Usage: download tv shows
URL: http://<your_pi_ip_here>:8989
```
