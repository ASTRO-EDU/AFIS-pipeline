#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $script_dir

pip install -r rta-transient-receiver/requirements.lock
pip install -r requirements.txt
pip install -e rta-transient-receiver/ 
pip install -e .