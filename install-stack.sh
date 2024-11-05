#!/bin/bash

echo enter debrid token ; read debrid_token ; export debrid_token

# update
echo "updating system..."
commands=("apt update; apt -y upgrade; apt dist-upgrade; apt -y autoclean; apt -y autoremove")
for cmd in "${commands[@]}"; do eval "$cmd" > /dev/null 2> /dev/null || echo "error during ${cmd%%;*}"; done

# curl
echo "installing curl..."
apt install -y curl > /dev/null 2>&1 || echo "an error occurred during curl installation"

# docker
echo "installing docker..."
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1 && sh ./get-docker.sh > /dev/null 2>&1 && rm get-docker.sh > /dev/null 2>&1

# compose
echo "installing compose..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sh -c "curl -s -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
chmod +x /usr/local/bin/docker-compose
sh -c "curl -s -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# network
echo "creating docker network..."
docker network create -d bridge network > /dev/null 2>&1 || echo "error creating docker network"

# user
echo "creating docker user..."
adduser --disabled-password --gecos "" containers > /dev/null 2>&1 || { echo "error creating user"; }
echo containers:containers | chpasswd > /dev/null 2>&1 || { echo "error setting password"; }
usermod -aG docker containers > /dev/null 2>&1 || { echo "error adding user to docker group"; }

# directories
echo "creating directories..."
mkdir -p /mnt/realdebrid /mnt/symlinks/downloads/complete/{radarr,sonarr}
chown -R containers:containers /mnt/{realdebrid,symlinks/downloads/complete/{radarr,sonarr}}

# config prowlarr
echo "creating prowlarr configuration..."
mkdir -p /var/lib/docker/volumes/root_prowlarr/_data/Definitions/Custom
curl -s -o /var/lib/docker/volumes/root_prowlarr/_data/Definitions/Custom/torrentio.yml \
https://raw.githubusercontent.com/dreulavelle/Prowlarr-Indexers/refs/heads/main/Custom/torrentio.yml

# config rclone
echo "creating rclone configuration..."
mkdir -p /var/lib/docker/volumes/root_rclone/_data
cat << EOF > /var/lib/docker/volumes/root_rclone/_data/rclone.conf
[zurg]
type = webdav
url = http://zurg:9999/dav
vendor = other
pacer_min_sleep = 0

[zurghttp]
type = http
url = http://zurg:9999/http
no_head = false
no_slash = false
EOF

# config zurg
echo "creating zurg configuration..."
mkdir -p /var/lib/docker/volumes/root_zurg/_data/app
cat << EOF > /var/lib/docker/volumes/root_zurg/_data/app/config.yml
zurg: v1
token: $debrid_token
check_for_changes_every_secs: 10
enable_repair: true
auto_delete_rar_torrents: true
on_library_update: sh plex_update.sh "$@"
directories:
  shows:
    group_order: 20
    group: media
    filters:
      - has_episodes: true

  movies:
    group_order: 30
    group: media
    only_show_the_biggest_file: true
    filters:
      - regex: /.*/
EOF

# config plex update
echo "creating plex update script..."
ip_address=$(hostname -I | awk '{print $1}')
cat << EOF > /var/lib/docker/volumes/root_zurg/_data/app/plex_update.sh
#!/bin/bash

plex_url="http://$ip_address:32400"
token="BZwbLQybSYocwPPW9UQm"
zurg_mount="/mnt/realdebrid"
section_ids=\$(curl -sLX GET "\$plex_url/library/sections" -H "X-Plex-Token: \$token" | xmllint --xpath "//Directory/@key" - | grep -o 'key="[^"]*"' | awk -F'"' '{print \$2}')
for arg in "\$@"
do
    parsed_arg="\${arg//\\\\}"
    echo \$parsed_arg
    modified_arg="\$zurg_mount/\$parsed_arg"
    echo "detected update on: \$arg"
    echo "absolute path: \$modified_arg"
    for section_id in \$section_ids
    do
        echo "Section ID: \$section_id"
        curl -G -H "X-Plex-Token: \$token" --data-urlencode "path=\$modified_arg" \$plex_url/library/sections/\$section_id/refresh
    done
done
echo "all updated sections refreshed"
EOF

# config plex server
echo "creating plex configuration..."
mkdir -p "/var/lib/docker/volumes/root_plex/_data/Library/Application Support/Plex Media Server"
cat << EOF > "/var/lib/docker/volumes/root_plex/_data/Library/Application Support/Plex Media Server/Preferences.xml"
<?xml version="1.0" encoding="utf-8"?>
<Preferences
    OldestPreviousVersion="1.41.1.9057-af5eaea7a"
    MachineIdentifier="ebb4e524-43ec-424d-8f47-3cf8dd655cc7"
    ProcessedMachineIdentifier="b8efdd1ed8a1a3bfd177542904548acd5cf3a0f7"
    AnonymousMachineIdentifier="e7f537e9-b2af-4436-836c-95192964cb90"
    MetricsEpoch="1"
    AcceptedEULA="1"
    GlobalMusicVideoPathMigrated="1"
    PublishServerOnPlexOnlineKey="0"
    PlexOnlineToken="BZwbLQybSYocwPPW9UQm"
    PlexOnlineUsername="aristosv"
    PlexOnlineMail="aristos@aristos.net"
    CertificateUUID="550c510a3cb743af967965072b251bc0"
    PubSubServer="139.162.215.242"
    PubSubServerRegion="lhr"
    PubSubServerPing="199"
    CertificateVersion="3"
    LanguageInCloud="1"
/>
EOF

# stack
echo "downloading stack..."
curl -O https://raw.githubusercontent.com/aristosv/mediastack/refs/heads/master/docker-compose.yml

# install
echo "installing stack..."
docker compose up -d
