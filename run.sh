#!/bin/bash

nextflow kuberun main.nf -pod-image 'cerit.io/nextflow/nextflow:22.06.1' \
	-c nextflow.config  --input /mnt/shared/MedGen/ACGT/src_parabricks/config/run4_mergedConf.tsv
