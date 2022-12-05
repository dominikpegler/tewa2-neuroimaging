# tewa2-neuroimaging
Analyzing fMRI data using python

## Create conda environment

`conda env create -f environment.yml`

## Includes the course repo as submodule

To clone the repo incl. the submodule run

`git clone --recursive https://github.com/dominikpegler/tewa2-neuroimaging`


To include the submodule afterwards run

`git submodule update --init --recursive`

To update the submodule run

`git submodule update`

## Open the notebooks on your local machine in a docker environment including FSL 5.0

`docker-compose up`

Open `localhost:8890` in your browser
