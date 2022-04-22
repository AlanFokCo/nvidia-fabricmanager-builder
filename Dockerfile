ARG VERSION

FROM centos:7 as build

USER root

RUN mkdir /work && \
    mkdir /work/SPEC && \
    mkdir /work/SOURCE 

COPY ./fabricmanager.spec /work/SPEC/fabricmanager.spec
COPY ./run.sh /run.sh
RUN chomd +x /run.sh && \
    yum install -y rpm-build wget tar

ENTRYPOINT [ "sh", "-c", "/run.sh ${VERSION}" ]
