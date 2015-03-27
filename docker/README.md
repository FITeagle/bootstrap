# FITeagle Docker image

This is an example Dockerfile with [Future Internet Testbed Experimentation and Management Framework](https://github.com/FITeagle).

## Building on your own

    docker build --no-cache --tag=fiteagle2bin .

## Usage

To boot in debug mode

    docker run --rm -it --name=ft2 -p 8443:8443 -p 9990:9990 fiteagle2bin

Testing the installation of FT2 by running xmlRPC commands

    docker run --rm -it --name=ft2 -p 8443:8443 fiteagle2bin
    ./xmlrpc-client.sh -t https://localhost:8443/sfa/api/am/v3 GetVersion
    ./xmlrpc-client.sh -t https://localhost:8443/sfa/api/am/v3 listRecources

To boot with custom wildfly arguments

    docker run --rm -it --name=ft2 -p 8443:8443 -p 9990:9990 --env WILDFLY_ARGS="-bmanagement 0.0.0.0" fiteagle2bin

To boot with custom command

    docker run --rm -it --name=ft2 -p 8443:8443 fiteagle2bin /opt/fiteagle/bootstrap/fiteagle.sh help

## Extending the image

To be able to create a management user to access the administration console create a Dockerfile with the following content

    FROM fiteagle2bin
    RUN /opt/fiteagle/server/bin/add-user.sh admin Admin#70365 --silent
    CMD ["/opt/fiteagle/bootstrap/fiteagle.sh", "startJ2EE", "-bmanagement", "0.0.0.0"]

Then you can build the image:

    docker build --tag=fiteagle2bin-admin .

Run it:

    docker run -it -p 9990:9990 fiteagle2bin-admin

The administration console should be available at http://localhost:9990.

## Image internals [updated 2015-03-27]

This image extends the [`java:7-jre`](https://github.com/docker-library/java/tree/master/openjdk-7-jre) image.

WildFly is installed in the `/opt/fiteagle/server` directory.

## Source

The source is [available on GitHub](https://github.com/FITeagle/bootstrap/tree/master/docker).

## Issues

Please report any issues or file RFEs on [GitHub](https://github.com/FITeagle/bootstrap/issues).
