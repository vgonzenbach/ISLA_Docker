FROM rocker/tidyverse:3.6.3
WORKDIR /
COPY --from=neurodocker:isla /opt .

RUN         Rscript -e "\
            chooseCRANmirror(graphics=FALSE, ind=60); \
            install.packages(c('parallel', 'methods', 'fslr', 'rlist', 'neurobase', 'dplyr', 'geepack', 'argparser')); \
            source('https://neuroconductor.org/neurocLite.R'); neuro_install(c('ANTsR', 'extrantsr'), release='stable');"

COPY isla isla
COPY run_ISLA.R run_ISLA.R

RUN Rscript -e "install.packages('./isla', repos = NULL, type='source')" 
           #&& rm -rf isla

ENTRYPOINT ["Rscript", "run_ISLA.R"]

