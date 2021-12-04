#!/bin/bash
lab-init () {
        source ~/venv/lab/bin/activate
        if [ $# -eq 0 ]; then
                source ~/lab/rc/lab
  else
                source ~/lab/rc/$1
  fi
}

k () {
        kinit username
}

grip () {
        grep -vE '^#|^$' $1
}

