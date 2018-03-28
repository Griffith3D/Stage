#!/bin/bash
host=$(hostname)
reg="^avocatbox-(.*?)$"

if [[ $host =~ $reg ]]; then
    echo "Adding ssh key to gitlab"
    ssh-keygen -f /home/vagrant/.ssh/id_rsa -N ''
    chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
    chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub
    curl -XPOST --header "PRIVATE-TOKEN: $1" --header 'Content-Type: application/json' 'http://gitlab.tools.mon-avocat.fr/api/v4/user/keys' --data "{\"title\": \"vagrant@$host\", \"key\": \"`< /home/vagrant/.ssh/id_rsa.pub`\"}"
fi
