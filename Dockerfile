
FROM arm64v8/ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apt-utils && apt-get upgrade -y

RUN apt-get install -y python3 python3-pip rsync vim wget curl pigz pkg-config git samtools minimap2 liblzma-dev libbz2-dev libblas-dev liblapack-dev

RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get install -y nodejs

# handle python and jupyter stuff
COPY WHEELS/* /tmp/
RUN pip3 install --upgrade pip \
    && pip install wheel setuptools \
    && pip install pybind11 \
    && pip install Cython --find-links file:///tmp \
    && pip install matplotlib scipy pandas pysam binlorry biopython snakemake==5.8.1 --find-links file:///tmp \
    && pip install git+https://github.com/artic-network/Porechop.git@v0.3.2pre \
    && pip install git+https://github.com/artic-network/fieldbioinformatics.git

# including gosu so that we can avoid the nastiness of colliding UIDs and write error
COPY gosu-arm64 /tmp/gosu

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
    && cd /opt/ \
    && mv /tmp/gosu /usr/local/bin/gosu \
    && chmod +x /usr/local/bin/gosu

RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -fR /tmp/* \
    && mkdir /data \
    && mkdir /data/pass \
    && mkdir /data/annotations \
    && chmod -R 777 /data \
    && cd /data \
    && wget https://raw.githubusercontent.com/artic-network/artic-ncov2019/master/simulated_reads.tgz \
    && tar -zxvpf simulated_reads.tgz \
    && mv simulated_reads/* pass \
    && rm -f simulated_reads.tgz \
    && cd /opt \
    && git clone --recursive https://github.com/artic-network/artic-ncov2019.git 

RUN groupadd -g 1001 -r ont \
    && useradd -r -u 999 -g ont ont -s /bin/bash \
    && mkdir /home/ont \
    && chown ont:ont /home/ont \
    && chown -R ont /opt

USER ont:ont

RUN cd /opt \
    && git clone https://github.com/artic-network/rampart.git  \
    && cd rampart \
    && npm install \
    && npm run build \
    && npm update 

COPY docker_workflow.sh /tmp/docker_workflow.sh
RUN cp /tmp/docker_workflow.sh /opt/docker_workflow.sh \
    && chmod +x /opt/docker_workflow.sh

USER root:root

EXPOSE 3000 3001

ENTRYPOINT ["/opt/docker_workflow.sh"]
#ENTRYPOINT ["/bin/bash"]
