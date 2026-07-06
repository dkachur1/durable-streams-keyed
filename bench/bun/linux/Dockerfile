# Same-machine Linux head-to-head: patched Rust durable-streams (WITH the
# target_os="linux" zero-copy paths compiled) vs Prisma's Bun server, both run
# inside ONE Linux container on the same host, driven by the same oha harness.
FROM rust:1.89-bookworm

# jq + curl + git + unzip; build-essential for native crates
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq curl git ca-certificates unzip pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Bun runtime for prisma/streams
ENV BUN_INSTALL=/usr/local/bun
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -s /usr/local/bun/bin/bun /usr/local/bin/bun
ENV PATH=/usr/local/bun/bin:$PATH

# prisma/streams pinned to the same commit as the macOS run
RUN git clone https://github.com/prisma/streams /app/prisma-streams \
    && cd /app/prisma-streams \
    && git checkout b8918773b1455e1a8197ba6b653965f257902929 \
    && bun install

# Build the patched Rust server (compiles the Linux zero-copy path)
COPY server-src /app/server-src
RUN cd /app/server-src \
    && cargo build --release \
    && cp target/release/durable-streams-server /app/durable-streams-server \
    && rm -rf target

# oha load generator — pinned to MATCH the macOS bench (1.14.0), so the load
# generator is identical on both sides of the comparison. (1.14.0 uses
# `--output-format json`, same as the harness; older 1.4.7 renamed it.)
RUN cargo install oha --locked --version 1.14.0

COPY bench-keyed.sh /app/bench-keyed.sh
COPY bench-bun-keyed.sh /app/bench-bun-keyed.sh
COPY bench-bun-base.sh /app/bench-bun-base.sh
COPY run-in-container.sh /app/run-in-container.sh
RUN chmod +x /app/*.sh

CMD ["/app/run-in-container.sh"]
