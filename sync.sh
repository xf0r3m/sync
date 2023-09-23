#!/bin/bash

#Config file:
source ~/.sync.d/sync.conf;

#Script file:

# Check there is a notify-send program installed on the system
which notify-send
isNotifySend=$?

#Function section:

# Check is local directory is a Git repository
function is_ldir_a_git_repo() {
  cd ${LDIR}
  git status > /dev/null 2>&1;
  return $?;
}

# Check is local directory is a clone of remote directory (just git clone)
function is_ldir_a_rdir_clone() {
  cd ${LDIR};
  git remote get-url origin | grep -q ${RDIR}
  return $?;
}

# Push changes to remote repo
function update_rdir() {
  cd ${LDIR};
  git add --all;
  git commit -m "Pushing changes.";
  git push -u origin main;
  if [ $? -eq 0 ]; then
    output "Remote directory is now up to date." "ok";
    return 0;
  else
    output "Problem ocurred when trying update remote directory" "warn";
    return 1;
  fi
}

# Create git repo on local directory
function initialize_ldir_git() {
  cd ${LDIR};
  git init -b main;
  git remote add origin ssh://${RUSER}@${RSERVER}${RDIR};
  return $?;
}

# Clone local directory from remote repo. Just clone.
function clone_rdir() {
  git clone ssh://${RUSER}@${RSERVER}${RDIR} ${LDIR}
  if [ $? -eq 0 ]; then
    output "Local directory was already cloned from remote directory." "ok";
  else
    output "Problem ocurred when trying to clone remote directory." "warn";
  fi
}

# Getting info about local dir updates, before pull
function get_update_info() {
  cd ${LDIR};
  git remote update > /dev/null 2>&1;
}

# Determining on git status hints, there updates for local directory
function is_ldir_need_to_update() {
  cd ${LDIR};
  git status | grep -q 'git pull';
  return $?; 
}

# Here is the same as above, but to other side
function is_rdir_need_to_update() {
  cd ${LDIR};
  git status | grep -Eq 'git add|git push'
  return $?;
}

# Pulling commits from remote repo
function update_ldir() {
  cd ${LDIR};
  git pull > /dev/null 2>&1;
  if [ $? -eq 0 ]; then
    output "Local directory now is up to date." "ok";
  else
    output "Problem occured when trying update local directory." "warn";
  fi
}

# Hard to get this, if u using repos in normal way. The most popular way to get
# this isn't even implemented in this script. For future use, maybe.
function is_ther_conflict() {
  cd ${LDIR};
  git push -u origin main | grep -q 'rejected';
  if [ $? -eq 0 ]; then
    output "Conflict ocurred. There are significant diffrences betwen local and remote dirs. Move changes outside local directory and delete him. Try synchronize dirs once again and put changes back" "bad";
  else
    output "Problem ocurred when trying update remote directory." "warn";
  fi
}

# Simple way to comunicate with user. If u have notify-send command, you get
# notifications, if not just type messages in stdout in terminal.
function output() {
  argv1=$@;
  icon=$(echo $argv1 | sed 's,\ ,\n,g' | tail -1);
  msg=$(echo $argv1 | sed -e "s,\ $icon,,g" -e 's/^[[:space:]]*//g');
  
  if [ "$icon" = "ok" ]; then
    nsIcon="emblem-synchronizing";
  elif [ "$icon" = "warn" ]; then
    nsIcon="dialog-warning";
  elif [ "$icon" = "bad" ]; then
    nsIcon="process-stop";
  fi
  
  if [ $isNotifySend -eq 0 ]; then
    notify-send "Sync" "$msg" --icon=$nsIcon
  else
    echo "$msg";
  fi
}

# Authentication with PKI is required, for this script, so if don't point any
# key in config file, script will generate one pair and try upload them to the
# server.
if [ ! "$KEYFILE" ]; then
  ssh-keygen -f ${HOME}/id_rsa
  ssh-copy-id ${SSHOPTS} -i ${HOME}/id_rsa ${RUSER}@${RSERVER}
fi

# Check there is a remote directory
ssh ${SSHOPTS} ${RUSER}@${RSERVER} "[ -d ${RDIR} ]";
if [ $? -ne 0 ]; then
  # If not, create the hole path and initialize remote dir as Git repository.
  ssh ${SSHOPTS} ${RUSER}@${RSERVER} "mkdir -p ${RDIR}"
  ssh ${SSHOPTS} ${RUSER}@${RSERVER} "cd ${RDIR} && git init --bare -b main";
  # Empty repo flag
  empty=0
fi

# Initializing local directory
if [ ! -d ${LDIR} ] && [ "$empty" ]; then
  # Just create dir structures and initialize them as git repos
  mkdir -p ${LDIR}
  initialize_ldir_git;
  output "Local directory was already created. Remote directory seems to be empty. Nothing to do. Exiting." "warn";
  exit 0;
elif [ -d ${LDIR} ] && [ "$empty" ]; then
  # Local dir already exist
  is_ldir_a_git_repo;
  if [ $? -eq 0 ]; then
    # Local dir is git repo
    is_ldir_a_rdir_clone;
    if [ $? -eq 0 ]; then
      # Local dir is remote repo clone. Push dir content to remote repo.
      update_rdir;
      exit 0;
    else
      # Local dir is other repo. Refusing to use it.
      output "Local directory is other repository than remote directory." "bad";
      exit 1;
    fi
  else
    # Local dir isn't a repo, initialize them and push first commit.
    initialize_ldir_git;
    update_rdir;
    exit 0;
  fi
elif [ ! -d ${LDIR} ] && [ ! "$empty" ]; then
  # Local directory doesn't exist, but remote dir isn't empty. Clone them.
  clone_rdir;
  exit 0;
fi 
# Getting update info from remote repo
get_update_info;
# Determining that need to pull commits 
is_ldir_need_to_update;
ldir_update=$?;
# or push to remote
is_rdir_need_to_update;
rdir_update=$?;
if [ $ldir_update -eq 0 ]; then
  update_ldir;
elif [ $rdir_update -eq 0 ]; then
  update_rdir;
  if [ $? -ne 0 ]; then
    is_ther_conflict;
  fi
else
  # If everything is up to date, nothing to do.
  output "Everything is up to date." "ok";
fi
