#!/bin/bash

cliphist list | fuzzel --dmenu --prompt "Clip ❯ " --width 60 | cliphist decode | wl-copy
