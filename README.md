# docker-phpapplication-template
These are set of files to bootstrap a php application inside a docker container

## Getting started

### Update the fig.yml file
The fig file is used to start the container. Edit this file to customize the container's parameters.

### Update the config/start.sh file
This file contains the application parameters. Edit it to be able create the appropriate MySQL user and database.

### Build the image
Issue the command : docker build . --tag="yourusername/yourimagename:yourtag"

__Note 1__: Replace the yourusername, yourimagename and yourtag by the appropriate values.
__Note 2__: You must use the same //yourimagename// in the fig.yml file 

### Start the container
Issue the command : fig up


