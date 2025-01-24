# Docker 
This directory contains scripts relating to Quality Of Life improvements for Docker or container related commands 

## inspect-all-containers.sh
This script used in the following manner:
```
./inspect-all-containers.sh
```
This script writes the output of a series of *Docker* commands to a file `running-containers.log`.
## install-editors.sh
This script used in the following manner with one argument:
```
./install-editors.sh <Container-ID>
```
This command installs an editor (using apt) inside of the specified container using `docker exec`.

## install-editors.sh
This script used in the following manner with one argument:
```
./shell.sh <Container-ID>
```

This script runs the *bash* shell in the specified container.