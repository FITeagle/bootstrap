#!/bin/bash

function removeOldRuby {
 apt-get -y --purge remove ruby-rvm ruby ruby1.9.3
 rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
 apt-get -y autoremove
}

function installNeededLibs {
 apt-get install -y build-essential libxml2-dev libxslt-dev libssl-dev
}

function installRuby {
 \curl -L https://get.rvm.io | bash -s stable
 source /etc/profile.d/rvm.sh
 rvm install ruby-1.9.3-p286 --autolibs=4
 rvm use ruby-1.9.3-p286
 rvm gemset create omf
 rvm use ruby-1.9.3-p286@omf --default

 rvm current; ruby -v
}

function installNepiEC {
 (
 curl -s http://nepi.inria.fr/code/nepi/archive/652bc2e46cfe.tar.gz|tar xzf -
 mv nepi-652bc2e46cfe nepi
 echo "Setup the environment:"
 echo "  export PYTHONPATH=\$PYTHONPATH:$(pwd)/nepi/src"

 curl -s -O https://raw.github.com/FITeagle/bootstrap/master/resources/nepi3/nepi3_example_ping.py
 mv nepi3_example_ping.py nepi
 echo "Run the first experiment:"
 echo "  python nepi/nepi3_example_ping.py"
 )
}

function startOmfRc {
 start omf_rc
}

#removeOldRuby
#installNeededLibs
#installRuby
installNepiEC
#startOmfRc
