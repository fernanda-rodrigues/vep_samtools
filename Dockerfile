FROM ensemblorg/ensembl-vep:release_100.0
LABEL maintainer="Fernanda Martins Rodrigues <fernanda@wustl.edu>"
LABEL description="Vep helper image"

USER root

RUN apt-get update -y && apt-get install -y \
	libncurses5-dev \
	zlib1g-dev \
	libbz2-dev \
	liblzma-dev \
	libcurl3-dev \
	libfile-copy-recursive-perl \
	libipc-run-perl \
	wget

WORKDIR /usr/src

# Samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
	tar jxf samtools-1.9.tar.bz2 && \
	rm samtools-1.9.tar.bz2 && \
	cd samtools-1.9 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/samtools-1.9 

#necessary because some legacy cwl files still refer to vep (the current name) as variant_effect_predictor.pl
WORKDIR /
RUN ln -s /opt/vep/src/ensembl-vep/vep /usr/bin/variant_effect_predictor.pl

WORKDIR /opt/vep/src/ensembl-vep
RUN perl INSTALL.pl --NO_UPDATE

RUN mkdir -p /opt/lib/perl/VEP/Plugins
WORKDIR /opt/lib/perl/VEP/Plugins

RUN wget https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/Downstream.pm \
	https://raw.githubusercontent.com/griffithlab/pVACtools/master/pvactools/tools/pvacseq/VEP_plugins/Wildtype.pm \
	https://raw.githubusercontent.com/griffithlab/pVACtools/master/pvactools/tools/pvacseq/VEP_plugins/Frameshift.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/CADD.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/REVEL.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/ExACpLI.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/ExACpLI_values.txt \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/LoFtool.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/LoFtool_scores.txt \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/SpliceRegion.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/dbNSFP.pm \
	https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/100/dbNSFP_replacement_logic

COPY vcf_check.pl /usr/bin/vcf_check.pl

USER /opt/vep/src/ensembl-vep/vep
