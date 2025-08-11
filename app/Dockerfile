# ---- build ----
FROM golang:1.22-alpine AS build
WORKDIR /src

# modules
COPY go.mod ./
RUN go mod download

# source
COPY main.go ./

# build (let the runner’s arch drive it; no ldflags, no cross-compile)
RUN CGO_ENABLED=0 go build -o /out/app ./main.go

# ---- run ----
FROM scratch
COPY --from=build /out/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
