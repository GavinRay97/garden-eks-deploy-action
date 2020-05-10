FROM gardendev/garden-aws
COPY --from=lachlanevenson/k8s-kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]