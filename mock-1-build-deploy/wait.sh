#!/bin/bash
echo "Preparing exam environment, please wait..."
while [ ! -f /tmp/.setup-done ]; do sleep 2; done
clear
echo "Environment ready. Good luck!"
