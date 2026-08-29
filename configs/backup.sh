# shellcheck disable=SC2148

bucket="jstanger-$(hostname)-backup"
storage_class="DEEP_ARCHIVE"

ignored=(
	"/var/run/docker.sock"
	"/var/lib/docker"
	"/var/lib/postgresql/17/data" # db handled via pg_dumpall in separate script
	"/storage"
	"/downloads"
	# pseudo/virtual filesystems commonly bind-mounted by privileged containers
	# (e.g. cAdvisor mounts /, /sys, /var/run, /dev/disk)
	"/proc"
	"/sys"
	"/dev"
	"/run"
	"/var/run"
)

all=$(docker ps -aq)

dirs=()
if [[ -n "$all" ]]; then
	# mapfile accounts for spaces in paths
	# shellcheck disable=SC2086
	mapfile -t dirs < <(docker inspect --format '{{json .Mounts}}' $all | jq -r '.[] | select(.Type == "bind") | .Source')
fi

is_ignored() {
	local dir=$1
	[[ "$dir" == "/" ]] && return 0
	for entry in "${ignored[@]}"; do
		if [[ "$dir" == "$entry" || "$dir" == "$entry"/* ]]; then
			return 0
		fi
	done
	return 1
}

sync_dir() {
	local src=$1
	local dest=$2
	shift 2

	echo "Backing up $src"
	aws s3 sync "$src" "$dest" \
		--storage-class "$storage_class" \
		--no-progress \
		--only-show-errors \
		--delete \
		"$@"
}

for dir in "${dirs[@]}"; do
	if is_ignored "$dir"; then
		continue
	fi

	if [ ! -d "$dir" ]; then
		continue
	fi

	sync_dir "$dir" "s3://$bucket$dir"
done

sync_dir /etc/stacks "s3://$bucket/etc/stacks" --exclude '.env'