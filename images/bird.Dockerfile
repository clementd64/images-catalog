FROM stagex/core-busybox AS source

WORKDIR /app
COPY --from=fetch --chown=user:user . /tmp/
RUN --network=none tar -xf /tmp/*.tar.gz --strip-components=1

FROM stagex/pallet-clang-gnu-busybox AS build
COPY --from=stagex/core-bash . /
COPY --from=stagex/core-ncurses . /
COPY --from=stagex/core-readline . /

WORKDIR /app
COPY --from=source /app .
RUN --network=none <<-EOF
	set -eu
	autoreconf -vif
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--runstatedir=/run
	make CC="cc --static" -j "$(nproc)"
	make DESTDIR=/rootfs install
EOF

FROM stagex/core-filesystem AS package
COPY --from=build /rootfs/ /
ENTRYPOINT [ "bird" ]
CMD [ "-f" ]
