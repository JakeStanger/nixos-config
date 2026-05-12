#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash hostname docker jq awscli

bucket="jstanger-$(hostname)-backup"
storage_class="DEEP_ARCHIVE"

ignored=(
	"/var/run/docker.sock" 
	"/var/lib/docker/volumes" 
	"/"
	"/var/lib/postgresql/17/data" # db handled via pg_dumpall in separate script
)

all=$(docker ps -aq)
# mapfile accounts for spaces in paths
# shellcheck disable=SC2086
mapfile -t dirs < <(docker inspect --format '{{json .Mounts}}' $all | jq -r '.[] | select(.Type == "bind") | .Source')

is_ignored() {
    local dir=$1
    for entry in "${ignored[@]}"; do
        [[ "$entry" == "$dir" ]] && return 0
    done
    return 1
}

# shellcheck disable=SC2068
for dir in ${dirs[@]}; do
	if is_ignored "$dir"; then
		continue
	fi

	echo "Backing up $dir"
	aws s3 sync "$dir" "s3://$bucket$dir" \
		--storage-class $storage_class \
		--delete
done

echo "Backing up /etc/stacks"
aws s3 sync /etc/stacks "s3://$bucket/etc/stacks" \
		--storage-class $storage_class \
		--delete

