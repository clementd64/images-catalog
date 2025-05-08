FROM stagex/pallet-go AS build
ARG VERSION

WORKDIR /app
COPY --from=fetch . .
RUN go mod download
COPY --from=schema krakend.json cmd/krakend-ce/schema/schema.json
RUN --network=none go build -trimpath -ldflags "${LDFLAGS} \
		-X github.com/krakendio/krakend-ce/v2/pkg.Version=${VERSION} \
		-X github.com/luraproject/lura/v2/core.KrakendVersion=${VERSION}" \
	-o krakend ./cmd/krakend-ce
RUN --network=none install -Dm755 -t /rootfs/usr/bin krakend

FROM stagex/core-filesystem
COPY --from=stagex/core-ca-certificates . /
COPY --from=build /rootfs/ /
ENTRYPOINT [ "krakend" ]
