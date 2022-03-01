FROM neurodocker:isla
ARG R_VERSION_MAJOR=3
ARG R_VERSION_MINOR=6
ARG R_VERSION_PATCH=3
ARG CONFIGURE_OPTIONS="--with-cairo --with-jpeglib --enable-R-shlib --with-blas --with-lapack"
RUN apt-get update && apt-get install -y \
            gfortran \
            git \
            git-annex \
            g++ \
            libreadline-dev \
            libx11-dev \
            libxt-dev \
            libpng-dev \
            libjpeg-dev \
            libcairo2-dev \   
            libssl-dev \ 
            libxml2-dev \
            libudunits2-dev \
            libgdal-dev \
            libbz2-dev \
            libzstd-dev \
            liblzma-dev \
            libpcre2-dev \
            locales \
            screen \
            texinfo \
            texlive \
            texlive-fonts-extra \
            vim \
            wget \
            xvfb \
            tcl8.6-dev \
            tk8.6-dev \
            cmake \
            curl \
            unzip \
            libcurl4-gnutls-dev \
            libgsl-dev \
            libcgal-dev \
            libglu1-mesa-dev \
            libglu1-mesa-dev \
            libtiff5-dev \
            python3 \
            python3-pip \
            && wget https://cran.rstudio.com/src/base/R-${R_VERSION_MAJOR}/R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz \
            && tar zxvf R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz \
            && rm R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz \
            && cd /R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH} \
            && ./configure ${CONFIGURE_OPTIONS} \ 
            && make \
            && make install 

RUN         Rscript -e "\
            chooseCRANmirror(graphics=FALSE, ind=60); \
            install.packages(c('parallel', 'methods', 'fslr', 'rlist', 'neurobase', 'dplyr', 'geepack', 'argparser')); \
            source('https://neuroconductor.org/neurocLite.R'); neuro_install(c('ANTsR', 'extrantsr'), release='stable');"

COPY app app

WORKDIR /app

RUN Rscript -e "install.packages('./isla', repos = NULL, type='source')" 
           #&& rm -rf isla

