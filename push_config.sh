#!/bin/bash

# add symbolic links to to packages from this directory to home folder
# requires `stow` package to be installed on the system

stow -v --defer push_config.sh -t ~/ */
