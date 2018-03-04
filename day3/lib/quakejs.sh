#!/usr/bin/env bash

apt-get update -y
apt-get install -y curl git build-essential

# install nodejs and npm
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs

# Install quakejs
git clone --recursive https://github.com/rcherrueau/quakejs.git /quakejs --depth 1
cd /quakejs
npm install

# Make the server.cfg file
cat > /server.cfg  <<EOF
seta sv_hostname "CHANGE ME"
seta sv_maxclients 20
seta g_motd "OMH QuakeJS"
seta g_quadfactor 3
seta g_gametype 0
seta timelimit 15
seta fraglimit 25
seta g_weaponrespawn 3
seta g_inactivity 3000
seta g_forcerespawn 0
seta rconpassword "NOP"
set d1 "map q3dm7 ; set nextmap vstr d2"
set d2 "map q3dm17 ; set nextmap vstr d1"
vstr d1
EOF

# Set `content.quakejs.com` as the content server
cat > bin/web.json <<EOF
{ "content": "content.quakejs.com" }
EOF
