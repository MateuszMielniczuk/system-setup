#!/bin/bash
# Private data kept out of git (wallet backups, calendar, notes, ...), synced by Syncthing.
# Sourced by other scripts: provides $SYSTEM_DATA.
SYSTEM_DATA="${SYSTEM_DATA:-$HOME/Documents/system-data}"
