#!/bin/bash

FILE=~/.ssh/known_hosts
if [ -f "$FILE" ]; then
  mv ~/.ssh/known_hosts ~/.ssh/known_hosts-old
  BOL=1
fi
ansible-playbook -i hosts arch-install.yml
if [ "$BOL" == 1 ]; then
  rm ~/.ssh/known_hosts
  mv ~/.ssh/known_hosts-old ~/.ssh/known_hosts
fi
