#!/bin/bash

notify-send -u critical -i battery "Låg batterinivå" "$(acpi | awk '{print $4}' | tr -d ,)"
