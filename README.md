# mediastack
Sonarr / Radarr / Jackett / Deluge - Raspberry Pi installation script

bash <(curl -s https://raw.githubusercontent.com/aristosv/mediastack/master/mediastack)

Run the command above on a Raspbery Pi running Raspbian Stretch Lite, and you'll end up with Sonarr / Radarr / Jackett / Deluge installed in a containerized environment.

This is how you can access all the software:

Name: portainer
Usage: docker container management
URL: http://*:9000

Name: sonarr
Usage: download tv shows
URL: http://*:8989

Name: radarr
Usage: download movies
URL: http://*:7878

Name: jackett
Usage: api torrent tracker
URL: http://*:9117

Name: deluge
Usage: download manager
URL: http://*:8112
Pass: deluge
