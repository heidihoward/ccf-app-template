# Build
FROM mcr.microsoft.com/ccf/app/dev:2.0.7-sgx as builder
COPY . /src
RUN mkdir -p /build/
WORKDIR /build/
RUN CC="/opt/oe_lvi/clang-10" CXX="/opt/oe_lvi/clang++-10" cmake -GNinja /src && ninja

# Run
FROM mcr.microsoft.com/ccf/app/run:2.0.7-sgx

COPY --from=builder /build/libccf_app.enclave.so.signed /app/
COPY --from=builder /opt/ccf/bin/*.js /app/
COPY --from=builder /opt/ccf/bin/keygenerator.sh /app/ 
COPY ./config/cchost_config.json /app/
WORKDIR /app/
RUN /app/keygenerator.sh --name member0 --gen-enc-key

EXPOSE 8080/tcp

CMD ["/usr/bin/cchost", "--config", "/app/cchost_config.json"]