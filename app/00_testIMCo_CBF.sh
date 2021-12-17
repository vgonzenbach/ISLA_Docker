#!/bin/bash

for job_index in (1 2); do
    Rscript 00_testIMCo.R $job_index 2 gmd cbf 10 # argv=c("1", "2", "gmd", 'cbf', '10')
    Rscript 00_runIMCo.R $job_index 3 gmd cbf 10
    Rscript 00_runIMCo.R $job_index 4 gmd cbf 10
    Rscript 00_testIMCo.R $job_index 2 gmd cbf 20 
    Rscript 00_runIMCo.R $job_index 3 gmd cbf 20
    Rscript 00_runIMCo.R $job_index 4 gmd cbf 20
done
