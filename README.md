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

## Start XMPP Server
```
./bootstrap/fiteagle.sh startXMPP
```

## Download and Configure OMF6 on Ubuntu
```
./bootstrap/resources/omf6/install_omf6.sh 
```
