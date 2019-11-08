FROM quay.io/mauilion/pause:3.1 as pause
FROM scratch
COPY --from=pause /pause /blue
CMD ["/blue"]
