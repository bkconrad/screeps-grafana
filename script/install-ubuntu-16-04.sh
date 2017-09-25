#!/bin/bash
set -ex
function log() {
  echo "[$(date)] $@"
}

TAG=v1.0
REPO="git@github.com:bkconrad/screeps-grafana.git"
DIR_NAME="screeps-grafana"
DATA_DISK=""
DATA_DIR="/data"

if [[ -z "$SCREEPS_EMAIL" ]] ; then
  log "You must set SCREEPS_EMAIL when using this script"
  exit 1
fi

if [[ -z "$SCREEPS_PASSWORD" ]] ; then
  log "You must set SCREEPS_PASSWORD when using this script"
  exit 1
fi

# install docker
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-convenience-script
curl -fsSL get.docker.com -o | sudo sh -
sudo usermod -aG docker "$(whoami)"

# install docker-compose
# https://docs.docker.com/compose/install/#install-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo apt-get install --yes git

if ![[ -z "$DATA_DISK" ]] ; then
  sudo mkdir -p "$DATA_DIR"
  if ! grep "$DATA_DISK" /etc/fstab ; then
    log "adding $DATA_DISK to /etc/fstab"
    echo "$DATA_DISK $DATA_DIR auto rw,user,auto 0 0" | sudo tee -a /etc/fstab
  fi

  if mount | grep "$DATA_DISK" ; then
    log "data disk already mounted"
  else
    log "mounting data disk $DATA_DISK"

    set +e
    mount "$DATA_DISK"
    set -e
  fi

  if mount | grep "$DATA_DISK" ; then
    log "$DATA_DISK mounted successfully"
  else
    log "Could not mount $DATA_DISK, formatting"
    mkfs.ext4 "$DATA_DISK"

    log "$DATA_DISK formatted successfully"
    mount "$DATA_DISK"
  fi
fi

cd
log "setting up screeps-grafana in pwd"

if ![[ -d "DIR_NAME" ]] ; then
  log "cloning $REPO into $DIR_NAME"
  git clone "$REPO" "$DIR_NAME"
fi

cd "$DIR_NAME"
git fetch "$TAG"
git reset --hard HEAD
git checkout "$TAG"

cat > docker-compose.env <<EOF
SCREEPS_EMAIL=$SCREEPS_EMAIL
SCREEPS_PASSWORD=$SCREEPS_PASSWORD
EOF

export GRAFANA_HOST_PORT="80"
docker-compose up --build -d
