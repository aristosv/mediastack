# mediastack
Sonarr / Radarr / Jackett / Deluge - Raspberry Pi installation script
```
bash <(curl -s https://raw.githubusercontent.com/aristosv/mediastack/master/mediastack)
```
Run the command above on a Raspbery Pi running Raspbian Stretch Lite.

It will install Sonarr / Radarr / Jackett / Deluge in a containerized environment.

This is how you can access all the web apps:

```
Name: portainer
Usage: docker container management
URL: http://<your_pi_ip_here>:9000
```
```
Name: sonarr
Usage: download tv shows
URL: http://<your_pi_ip_here>:8989
```
```
Name: radarr
Usage: download movies
URL: http://<your_pi_ip_here>:7878
```
```
Name: jackett
Usage: api torrent tracker
URL: http://<your_pi_ip_here>:9117
```
```
Name: deluge
Usage: download manager
URL: http://<your_pi_ip_here>:8112
Pass: deluge
```
