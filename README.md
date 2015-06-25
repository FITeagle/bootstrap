[![Build Status](https://travis-ci.org/FITeagle/bootstrap.svg?branch=master)](https://travis-ci.org/FITeagle/bootstrap)
[![Join the chat at https://gitter.im/FITeagle/support](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/FITeagle/support)

# FITeagle Bootstrap

Scripts and configurations to bootstrap the environment.
It can be used to bootstrap the envoriment directly on your mashine or virtualized by using Docker containers.

## Quick Start

### Automatically download, configure and run FITeagle incl. SFA interface
This method uses maven to compile and deploy the components
```
curl -fsSL fiteagle.org/bootstrap | bash -s init deployFT2 deployFT2sfa
```

### Automatically download, configure and run FITeagle incl. SFA interface
This method will download precompiled war files and does not use maven which is a lof **faster**
```
curl -fsSL fiteagle.org/bootstrap | bash -s init deployFT2binary deployFT2sfaBinary startJ2EE
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

## Using Docker containers

### Docker container for running fiteagle interactive

start by building an docker image based on the chekout of the bootstrap repository (_note:_ the source could be modified)
```
sudo docker rmi fiteagle2test; sudo docker build --rm --force-rm --tag=fiteagle2test .
```
now the docker image could be used (run) the same way as the fiteagle.sh script. 

```./bootstrap/fiteagle.sh deployFT2binary deployFT2sfaBinary startJ2EEdebug``` vs. ```docker run --rm -it --name=ft2test fiteagle2test deployFT2binary deployFT2sfaBinary startJ2EEdebug```.

Please keep in mind that the ```--rm``` option causes a removal of the container then the executable finshed.

If you want to run multiple commands and keep the data between them omit the ```--rm``` switch and use the following command for follow up commands: ```docker exec -t -i ft2test <cmd>```

the combined command ```docker run --rm -it --name=ft2test fiteagle2test deployFT2binary deployFT2sfaBinary startJ2EEdebug``` could be split in the following commands:
```shell
docker run -it --name=ft2test fiteagle2test deployFT2binary
docker exec -t -i ft2test deployFT2sfaBinary 
docker exec -t -i ft2test startJ2EEdebug
```
When the container is running the SFA test could be run inside like this ``` docker exec -t -i ft2test testFT2sfa```
