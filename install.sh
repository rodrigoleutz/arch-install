#!/bin/bash

mv ~/.ssh/known_hosts ~/.ssh/known_hosts-old
ansible-playbook -i hosts arch-install.yml
