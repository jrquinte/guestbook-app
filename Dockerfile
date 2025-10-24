# Stage 1: Build the Go application
FROM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go mod files (if they exist) and source code
COPY main.go .

# Initialize Go module and download dependencies
RUN go mod init guestbook && \
    go mod tidy

# Build the application
# CGO_ENABLED=0 for static binary
# -ldflags="-w -s" to reduce binary size
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o guestbook main.go

# Stage 2: Create minimal runtime image
FROM alpine:3.18

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/guestbook /app/guestbook

# Copy static files
COPY public/index.html /app/public/index.html
COPY public/script.js /app/public/script.js

# Optional: Add style.css and jquery if needed
COPY public/style.css /app/public/style.css
# COPY public/jquery.min.js /app/public/jquery.min.js

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/hello || exit 1

# Run the application
CMD ["./guestbook"]
