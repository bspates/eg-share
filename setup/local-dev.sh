#!/bin/bash
function update() {
  sudo apt-get update -y
}

function common() {
  update
  sudo apt-get install -y python-dev unzip vim wget git-core curl libpq-dev zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties
}

function postgresql() {
  sudo update-locale LANG=en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8
  . /etc/default/locale
  sudo apt-get install postgresql postgresql-contrib -y
}

function vagrantPostgresql() {
  sudo -u postgres createuser --superuser vagrant
  sudo -u postgres psql -U postgres -d postgres -c "alter user vagrant with password 'vagrant';"
  createdb -U vagrant -e shell_share -E UTF-8
}

function node() {
  curl -sL https://deb.nodesource.com/setup | sudo bash -
  sudo apt-get -y install nodejs
}

function globalNpmLibs() {
  sudo npm install -g grunt-cli forever coffee-script
}

function environmentVars() {
  sudo cp /vagrant/setup/shell_share.sh /etc/profile.d/
  cp /vagrant/setup/.npmrc /home/vagrant/
}

function lineSep() {
  for n in {1..20}
  do
    printf "="
  done
  printf "\n"
}

function title() {
  lineSep
  echo "$1"
  lineSep
}

set -e
title "Installing Everything"
common

title "Installing Postgresql"
postgresql
vagrantPostgresql

title "Installing Node"
node
globalNpmLibs

environmentVars

title "Finished Everything"