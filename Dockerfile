# Build stage
FROM golang:alpine AS builder
WORKDIR /app
COPY go.mod ./
# COPY go.sum ./ # Uncomment if you add dependencies and generate a go.sum
RUN go mod download
COPY *.go ./
# Compile the application for a Linux environment, statically linked
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Production stage
# We use a very small base image to keep the production environment secure and lightweight
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
# Copy the compiled binary from the builder stage
COPY --from=builder /app/main .

EXPOSE 8080
CMD ["./main"]
