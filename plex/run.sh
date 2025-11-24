#!/bin/bash

# ========== Color Codes ==========
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# ========== Helper Functions ==========
print_section() {
    echo -e "\n${BLUE}$1${NC}"
    echo "---------------------------------------------------------"
}

status_ok() {
    echo -e "${GREEN}done${NC}"
}

status_fail() {
    echo -e "${RED}failed${NC}"
}

# ===================== Root Check =====================
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ This script must be run as root."
  exit 1
fi

# ========== Parse docker-compose.yml ==========
compose_file="./docker-compose.yml"

# Extract container names and images
container_names=($(grep 'container_name:' "$compose_file" | awk '{print $2}'))
images=($(grep 'image:' "$compose_file" | awk '{print $2}'))

if [[ ${#container_names[@]} -eq 0 || ${#images[@]} -eq 0 ]]; then
    echo -e "${RED}[ERROR] No container_name: or image: found in $compose_file${NC}"
    exit 1
fi

# ========== Check and Pull Only Newer Images ==========
print_section "Checking and updating images if needed"

for image in "${images[@]}"; do
    echo "Checking image: $image"
    local_digest=$(docker image inspect --format='{{index .RepoDigests 0}}' "$image" 2>/dev/null | cut -d'@' -f2)
    remote_digest=$(docker manifest inspect "$image" 2>/dev/null | jq -r '.manifests[0].digest')

    if [[ "$local_digest" == "$remote_digest" && -n "$local_digest" ]]; then
        echo "✅ Image is up-to-date: $image"
    else
        echo "⬇️ Pulling updated image: $image"
        docker pull "$image"
    fi
done

# ========== Stop Running Containers ==========
print_section "Stopping containers"
for container in "${container_names[@]}"; do
    echo "Stopping $container..."
    if docker stop "$container" > /dev/null 2>&1; then status_ok; else status_fail; fi
done

# ========== Remove Containers ==========
print_section "Removing containers"
for container in "${container_names[@]}"; do
    echo "Removing $container..."
    if docker rm "$container" > /dev/null 2>&1; then status_ok; else status_fail; fi
done

# ========== Ensure Named Volumes Exist ==========
print_section "Checking named Docker volumes"
defined_volumes=($(grep -A100 '^volumes:' "$compose_file" | grep -E '^\s+[a-zA-Z0-9_-]+:' | awk -F':' '{print $1}' | xargs))

for volume in "${defined_volumes[@]}"; do
    if docker volume inspect "$volume" > /dev/null 2>&1; then
        echo "✔ Volume '$volume' already exists"
    else
        echo "➕ Creating volume '$volume'..."
        if docker volume create "$volume" > /dev/null; then
            status_ok
        else
            status_fail
        fi
    fi
done

# ========== Ensure Bind-Mount Directories Exist ==========
print_section "Checking bind-mount directories"
bind_mounts=$(grep '^\s*-\s*/' "$compose_file" | cut -d':' -f1 | sed 's/^\s*-\s*//' | sort -u)

for path in $bind_mounts; do
    if [[ -e "$path" ]]; then
        echo "✔ $path exists"
    else
        echo "➕ Creating $path"
        mkdir -p "$path"
        if [[ $? -eq 0 ]]; then
            status_ok
        else
            echo -e "${RED}failed to create $path${NC}"
        fi
    fi
done

# ========== Rebuild Containers ==========
print_section "Generating new containers"
if docker compose up -d; then
    status_ok
else
    status_fail
    exit 1
fi


# ========== Remove Unused Images ==========
print_section "Removing unused images"
for image in $(docker images -q --filter "dangling=false" | sort | uniq); do
    # Tjek om image er i brug af nogen kørende eller stoppede container
    if docker ps -a --filter ancestor="$image" --format '{{.ID}}' | grep -q .; then
        continue  # image er i brug
    fi
    echo "🧹 Removing unused image: $image"
    docker rmi "$image" 2>/dev/null || echo "⚠️ Could not remove image: $image"
done


exit 0
                                                                                                                                                                                  
