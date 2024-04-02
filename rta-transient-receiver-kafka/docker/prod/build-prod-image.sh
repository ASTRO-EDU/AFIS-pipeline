#!/bin/bash

set -u
set -e

# Funzione per stampare l'help
print_help() {
    echo -e "\n\033[33mUsage: $0 [tag|branch]\033[0m"
    echo -e "\nIf no tag or branch is specified, 'main' will be used as the branch and 'latest' will be used as the image tag."
    echo -e "\nExamples:"
    echo -e "  $0                       # Uses 'main' as the branch and 'latest' as the tag"
    echo -e "  $0 feature-branch         # Uses 'feature-branch' as the branch and 'feature-branch' as the tag"
    echo -e "\nOptions:"
    echo -e "  --help                          # Displays this help message"
    echo -e "  [tag|branch]                    # Specifies the branch/tag to use"
    exit 0
}


# Controlla se è stato passato --help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    print_help
fi

# Imposta il branch (default a "main")
GIT_TAG_V=${1:-main}

# Se il branch è 'main', usa 'latest' per il tag dell'immagine
if [ "$GIT_TAG_V" == "main" ]; then
    IMAGE_TAG="latest"
else
    IMAGE_TAG="$GIT_TAG_V"
fi

PROD_TAG="rta_transient_kafka_receiver_prod"

# Mostra informazioni sui valori utilizzati
printf "\n\033[32m > Utilizzo branch/tag: ${GIT_TAG_V} \033[0m\n"
printf "\n\033[32m > Tag dell'immagine Docker: ${IMAGE_TAG} \033[0m\n"

# Costruzione e tagging dell'immagine Docker
printf "\n\033[32m > Costruzione immagine Docker... \033[0m\n\n"
docker build --build-arg REPO_BRANCH="$GIT_TAG_V" --tag "${PROD_TAG}:${IMAGE_TAG}" .

printf "\n\033[32m > Immagine Docker costruita con successo: ${PROD_TAG}:${IMAGE_TAG} \033[0m\n"
