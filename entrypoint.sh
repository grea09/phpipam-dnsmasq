#!/bin/bash
echo "Evaluating template files…"
# https://stackoverflow.com/questions/2914220/bash-templating-how-to-build-configuration-files-from-templates-with-bash
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < config.template.php > /app/phpipam-agent/config.php
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < phpipam.template.conf > /etc/dhcp/phpipam.conf

echo "Cron loop"
crond -f -l 8