# syntax=docker/dockerfile:1
ARG BASE_IMAGE

FROM rust:1.81.0-slim-bookworm AS builder

ARG TARGETPLATFORM
ARG MDBOOK_VERSION
ARG CARGO_TARGET
ARG MDBOOK_MERMAID_VERSION
ARG MDBOOK_TOC_VERSION
ARG MDBOOK_ADMONISH_VERSION
ARG MDBOOK_ALERTS_VERSION
ARG MDBOOK_PAGETOC_VERSION
ARG MDBOOK_YML_HEADER_VERSION

ENV CARGO_TARGET_DIR="/usr/local/cargo-target"

RUN rm -f /etc/apt/apt.conf.d/docker-clean &&
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update &&
    apt-get install --no-install-recommends -y \
        musl-tools \
        file
RUN rustup target add "${CARGO_TARGET}"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook --version "${MDBOOK_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-mermaid --version "${MDBOOK_MERMAID_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-mermaid)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-toc --version "${MDBOOK_TOC_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-toc)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-admonish --version "${MDBOOK_ADMONISH_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-admonish)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-alerts --version "${MDBOOK_ALERTS_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-alerts)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-pagetoc --version "${MDBOOK_PAGETOC_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-pagetoc)"
RUN --mount=type=cache,sharing=locked,target=/usr/local/cargo-target \
    cargo install mdbook-yml-header --version "${MDBOOK_YML_HEADER_VERSION}" --target "${CARGO_TARGET}" &&
    strip "$(which mdbook-yml-header)"

FROM ${BASE_IMAGE}

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
COPY --from=builder /usr/local/cargo/bin/mdbook /usr/bin/mdbook
COPY --from=builder /usr/local/cargo/bin/mdbook-mermaid /usr/bin/mdbook-mermaid
COPY --from=builder /usr/local/cargo/bin/mdbook-toc /usr/bin/mdbook-toc
COPY --from=builder /usr/local/cargo/bin/mdbook-admonish /usr/bin/mdbook-admonish
COPY --from=builder /usr/local/cargo/bin/mdbook-alerts /usr/bin/mdbook-alerts
COPY --from=builder /usr/local/cargo/bin/mdbook-pagetoc /usr/bin/mdbook-pagetoc
COPY --from=builder /usr/local/cargo/bin/mdbook-yml-header /usr/bin/mdbook-yml-header

WORKDIR /app
CMD [ "/usr/bin/mdbook" ]
