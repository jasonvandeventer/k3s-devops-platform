# ---- build ----
FROM golang:1.22-alpine AS build
WORKDIR /src

# Cache deps
COPY go.mod .
RUN go mod download

# Copy app and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/app .

# ---- run ----
FROM scratch
COPY --from=build /out/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
