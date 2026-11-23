#!/bin/bash

cliphist list | "$(dirname "$0")/menu.sh" --prompt "Clip" --width 60 | cliphist decode | wl-copy
