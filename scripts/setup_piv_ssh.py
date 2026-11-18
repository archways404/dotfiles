#!/usr/bin/env python3
"""Compatibility entry point; prefer the root SSH menu launchers on new machines."""
import sys
from ssh_setup import main

if __name__ == '__main__':
    main(['configure', *sys.argv[1:]])
