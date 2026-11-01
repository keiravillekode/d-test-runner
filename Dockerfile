FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c

ARG DMD_VERSION=2.113.1

# install.sh verifies every download against the D keyring with gpg,
# but silently skips verification if gpg is missing, so gpg is required here.
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        ca-certificates curl gcc gpg jq libc6-dev xz-utils && \
    curl -fsSL https://dlang.org/install.sh -o /tmp/install.sh && \
    bash /tmp/install.sh -p /opt/dlang install "dmd-${DMD_VERSION}" && \
    rm /tmp/install.sh && \
    printf '#!/bin/sh\nexec /opt/dlang/dmd-%s/linux/bin64/dmd "$@"\n' "${DMD_VERSION}" > /usr/bin/dmd && \
    chmod +x /usr/bin/dmd && \
    cp "/opt/dlang/dmd-${DMD_VERSION}/linux/bin64/dub" /usr/bin/dub && \
    apt-get purge --yes --auto-remove ca-certificates curl gpg xz-utils && \
    rm -rf /root/.gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
