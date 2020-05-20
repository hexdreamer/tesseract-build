#!/usr/bin/env python3

import json
import sys

with open ('configs.json', 'r') as f:
    config_map = json.loads(f.read())

configs = []
pkg_name = sys.argv[1]