# FITeagle Bootstrap

Scripts to bootstrap the environment.

## Download and Configure Server Components
```
bash -c "$(curl -fsSkL https://raw.github.com/fiteagle/bootstrap/master/fiteagle.sh)" bootstrap
```

## Start J2EE Server
```
./bootstrap/fiteagle.sh startJ2EE
```

## Deploy FITeagle Core
```
./bootstrap/fiteagle.sh deployCore
```

## Have a look at the admin GUI
```
open http://localhost:8080/native/gui/admin/console.html
```

## Start XMPP Server
```
./bootstrap/fiteagle.sh startXMPP
```

## Download and Configure OMF6 on Ubuntu
```
./bootstrap/resources/omf6/install_omf6.sh 
```

## Download NEPI3 EC and Example
```
./bootstrap/resources/nepi3/install_nepi3.sh 
```
