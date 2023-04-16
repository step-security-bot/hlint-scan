# syntax=docker/dockerfile:1

# We fetch and build a specific unreleased version of HLint as well,
# since a version of HLint with SARIF support has not been released yet.
#
# Once one has been, we may either continue to bundle the hlint binary
# together but at a more stable and official set of versions.
# Alternatively, we could have the action retrieve an hlint release
# automatically if one is not already available locally in the action.

FROM haskell:9.4.4-buster@sha256:a006fb82b5960beede4fd4317df55f1fb053c3b56fe95f7d8ae5d5c60a26713e AS build
RUN mkdir -p /src && \
    cd /src && \
    git clone https://github.com/haskell-actions/hlint-scan.git
WORKDIR /src/hlint-scan
RUN stack install hlint hlint-scan:exe:hlint-scan && \
    cp $(stack path --local-bin)/hlint $(stack path --local-bin)/hlint-scan /

FROM debian:buster-slim@sha256:4d208d79338beaa197912496d0791921a31d9c58fa6fbd299787fab37cc893dd
RUN apt-get --yes update && \
    apt-get --yes install ca-certificates && \
    apt-get --yes clean
COPY --from=build /hlint /hlint-scan /
ENTRYPOINT ["/hlint-scan"]
