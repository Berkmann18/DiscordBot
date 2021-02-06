#!/bin/bash
terraform init &&
notify-send -u low -a $TERM -i ../assets/avatar.png "TF Initiated" &&
./plan.sh &&
notify-send -u low -a $TERM -i ../assets/avatar.png "Plan complete" "DiscordBot TF plan done" &&
./run.sh && echo Done && notify-send -u low -a $TERM -i ../assets/avatar.png "DiscordBot Infra done"