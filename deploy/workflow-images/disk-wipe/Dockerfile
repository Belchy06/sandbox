ARG REGISTRY
FROM $REGISTRY/ubuntu:base
COPY wipe.sh /
RUN chmod +x ./wipe.sh
ENTRYPOINT ["./wipe.sh"]