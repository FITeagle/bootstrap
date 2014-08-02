[![Build Status](https://travis-ci.org/FITeagle/bootstrap.svg?branch=master)](https://travis-ci.org/FITeagle/bootstrap)

# FITeagle Bootstrap

Scripts and configurations to bootstrap the environment.

## Download and Configure Server Components
```
bash -c "$(curl -fsSkL https://raw.github.com/fiteagle/bootstrap/master/fiteagle.sh)" bootstrap
```

## Start J2EE Server
```
./bootstrap/fiteagle.sh startJ2EE
```

## Have a look at the J2EE Server Management Console. Default login is: admin/admin
```
http://localhost:9990/console/App.html
```

## Deploy FITeagle Core
```
./bootstrap/fiteagle.sh deployCore
```

## Have a look at the admin GUI
```
open http://localhost:8080/native/gui/admin/console.html
```

## Start SPARQL Server
```
./bootstrap/fiteagle.sh startSPARQL
```

## Have a look at the SPARQL GUI
```
open http://localhost:3030/sparql.html
```

## Submit the first query
```
SELECT ?s ?p ?o
FROM <http://localhost:3030/ds/data?default>
WHERE { ?s ?p ?o }
LIMIT 10
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
