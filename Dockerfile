# ---- Build Stage ----
FROM alpine:3.18 AS build

RUN apk add --no-cache \
    alpine-sdk cmake git zlib-dev openssl-dev gperf linux-headers

WORKDIR /app
RUN git clone --depth 1 --recurse-submodules --shallow-submodules \
    https://github.com/tdlib/telegram-bot-api.git

WORKDIR /app/telegram-bot-api
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install -- -j$(nproc)

# ---- Runtime Stage ----
FROM alpine:3.18

RUN apk add --no-cache libstdc++ libgcc openssl

COPY --from=build /app/telegram-bot-api/bin/telegram-bot-api /usr/local/bin/

RUN addgroup -S botapi && adduser -S -G botapi botapi
USER botapi

EXPOSE 8081

CMD ["sh", "-c", "telegram-bot-api --http-port=${PORT:-8081} --local --api-id=${TELEGRAM_API_ID} --api-hash=${TELEGRAM_API_HASH}"]
