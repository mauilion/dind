FROM quay.io/mauilion/pause:3.1 as pause
FROM scratch
COPY --from=pause /pause /true-blue
CMD ["/true-blue"]
