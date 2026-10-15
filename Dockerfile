FROM alpine:3.18

# Install build dependencies for telegram-bot-api
RUN apk add --no-cache \
    g++ \
    make \
    cmake \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    readline-dev \
    libressl-dev \
    linux-headers

# Clone and build telegram-bot-api from source
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /app/telegram-bot-api
WORKDIR /app/telegram-bot-api
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -- -j$(nproc) && \
    cp telegram-bot-api /usr/local/bin/ && \
    cd / && rm -rf /app/telegram-bot-api

# Expose the port Koyeb/Render expects
EXPOSE 8081

# Run the API server with local storage mode enabled (2GB limit)
CMD ["telegram-bot-api", "--http-port=8081", "--local"]
