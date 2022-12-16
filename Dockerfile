FROM ubuntu:22.04

# ubuntu 22.04 comes with Python 3.10

COPY requirements-spm.txt /tmp

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
    bc \
    ca-certificates \
    python3-pip \
    curl \
    dc \
    file \
    libfontconfig1 \
    libfreetype6 \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libglu1-mesa-dev \
    libgomp1 \
    libice6 \
    libopenblas-base \
    libxcursor1 \
    libxft2 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxt6 \
    nano \
    sudo \
    wget \
    graphviz \
    tree \
    unzip \
    && apt-get clean \
    && rm -rf \
     /tmp/hsperfdata* \
     /var/*/apt/*/partial \
     /var/lib/apt/lists/* \
     /var/log/apt/term*

RUN pip3 install --no-cache-dir --upgrade -r /tmp/requirements-spm.txt

# SPM PART

# Install MATLAB MCR in /opt/mcr/
ENV MATLAB_VERSION R2019b
ENV MCR_VERSION v97
ENV MCR_UPDATE 9
RUN mkdir /opt/mcr_install \
    && echo Installing MATLAB VERSION ${MATLAB_VERSION} \
    && mkdir /opt/mcr \
    && wget --progress=bar:force -P /opt/mcr_install https://ssd.mathworks.com/supportfiles/downloads/${MATLAB_VERSION}/Release/${MCR_UPDATE}/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_${MATLAB_VERSION}_Update_${MCR_UPDATE}_glnxa64.zip \
    && unzip -q /opt/mcr_install/MATLAB_Runtime_${MATLAB_VERSION}_Update_${MCR_UPDATE}_glnxa64.zip -d /opt/mcr_install \
    && /opt/mcr_install/install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent \
    && rm -rf /opt/mcr_install /tmp/*

# Install SPM Standalone in /opt/spm12/
ENV SPM_VERSION 12
ENV SPM_REVISION r7771
ENV LD_LIBRARY_PATH /opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64:${LD_LIBRARY_PATH}
ENV MCR_INHIBIT_CTF_LOCK 1
ENV SPM_HTML_BROWSER 0
# Running SPM once with "function exit" tests the succesfull installation *and*
# extracts the ctf archive which is necessary if singularity is going to be
# used later on, because singularity containers are read-only.
# Also, set +x on the entrypoint for non-root container invocations
RUN wget --no-check-certificate --progress=bar:force -P /opt https://www.fil.ion.ucl.ac.uk/spm/download/restricted/bids/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip \
    && unzip -q /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip -d /opt \
    && rm -f /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip \
    && /opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit \
    && chmod +x /opt/spm${SPM_VERSION}/spm${SPM_VERSION}

ENV LD_LIBRARY_PATH=""

# FSL PART

ENV FSLDIR="/opt/fsl-5.0.11" \
    PATH="/opt/fsl-5.0.11/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-5.0.11/bin/fsltclsh" \
    FSLWISH="/opt/fsl-5.0.11/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q" 

RUN echo "Downloading FSL (this can take some time) ..." \
    && mkdir -p /opt/fsl-5.0.11 \
    && curl -fL https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.11-centos6_64.tar.gz \
    | tar -xz -C /opt/fsl-5.0.11 --strip-components 1 \
    && echo "Installing FSL conda environment (this can take some time) ..." \
    && bash /opt/fsl-5.0.11/etc/fslconf/fslpython_install.sh -f /opt/fsl-5.0.11

EXPOSE 8890

WORKDIR /main

CMD ["jupyter", "lab", "--port=8890", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--ServerApp.token=''"]
