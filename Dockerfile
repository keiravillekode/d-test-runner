FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c

ARG DMD_VERSION=2.113.1

# install.sh verifies every download against the D keyring with gpg,
# but silently skips verification if gpg is missing, so gpg is required here.
#
# dmd only uses gcc as a linker driver, so skip the C compiler proper
# (cc1), the LTO compiler and the sanitizer runtimes.
RUN printf '%s\n' \
        'path-exclude=/usr/libexec/gcc/*/cc1' \
        'path-exclude=/usr/libexec/gcc/*/lto1' \
        'path-exclude=/usr/lib/x86_64-linux-gnu/lib*san.so*' \
        'path-exclude=/usr/lib/gcc/*/lib*san*' \
        > /etc/dpkg/dpkg.cfg.d/exclude-unused-gcc && \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        ca-certificates curl gcc gpg jq libc6-dev xz-utils && \
    curl -fsSL https://dlang.org/install.sh -o /tmp/install.sh && \
    bash /tmp/install.sh -p /opt/dlang install "dmd-${DMD_VERSION}" && \
    rm /tmp/install.sh && \
    printf '#!/bin/sh\nexec /opt/dlang/dmd-%s/linux/bin64/dmd "$@"\n' "${DMD_VERSION}" > /usr/bin/dmd && \
    chmod +x /usr/bin/dmd && \
    mv "/opt/dlang/dmd-${DMD_VERSION}/linux/bin64/dub" /usr/bin/dub && \
    cd "/opt/dlang/dmd-${DMD_VERSION}" && \
    rm -rf html man src/dmd linux/bin32 linux/lib32 && \
    cd / && \
    apt-get purge --yes --auto-remove ca-certificates curl gpg xz-utils && \
    rm -rf /root/.gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
