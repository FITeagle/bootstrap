[![Build Status](https://travis-ci.org/FITeagle/bootstrap.svg?branch=master)](https://travis-ci.org/FITeagle/bootstrap)
[![Join the chat at https://gitter.im/FITeagle/support](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/FITeagle/support)

# FITeagle Bootstrap

Scripts and configurations to bootstrap the environment.

## Quick Start 

### Automatically download, configure and run FITeagle incl. SFA interface
```
curl -fsSL fiteagle.org/bootstrap | bash -s init deployFT2 deployFT2sfa
```

### Have a look at the J2EE Server Management Console. Default login is: admin/admin
```
http://localhost:9990/console/App.html
```

## Further Setup

### Start XMPP Server
```
./bootstrap/fiteagle.sh startXMPP
```

### Download and Configure OMF6 on Ubuntu
```
./bootstrap/resources/omf6/install_omf6.sh 
```

### Download NEPI3 EC and Example
```
./bootstrap/resources/nepi3/install_nepi3.sh 
```
