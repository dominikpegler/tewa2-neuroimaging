# tewa2-neuroimaging
Analyzing fMRI data using python


## Includes the course repo as submodule

To clone the repo incl. the submodule run

`git clone --recursive https://github.com/dominikpegler/tewa2-neuroimaging`


To include the submodule afterwards run

`git submodule update --init --recursive`

To update the submodule run

`git submodule update`

## Open the notebooks on your local machine

The following command builds and starts a containerized jupyter environment including FSL 5.0

`docker-compose up`

Open `localhost:8890` in your browser
