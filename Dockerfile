FROM traefik:3.6.7

RUN apk add --no-cache openssl

# Copie du script d'entrée
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Définition du point d'entrée pour exécuter la génération de certificats
ENTRYPOINT ["/entrypoint.sh"]

# On redonne la commande par défaut de l'image traefik (qui sera passée à l'entrypoint via "$@")
CMD ["traefik"]
