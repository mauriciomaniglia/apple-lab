# Stage 1 - build
FROM swift:5.9 as builder
WORKDIR /app
COPY . .
# Build the executable
RUN swift build -c release -Xswiftc -static-stdlib

# Stage 2 - runtime
FROM swift:5.9-slim
WORKDIR /app
COPY --from=builder /app/.build/release/SportsCarAPI /app/SportsCarAPI
# copy resources if any (Public/Resources)
EXPOSE 8080
ENV PORT=8080
CMD ["/app/SportsCarAPI"]

