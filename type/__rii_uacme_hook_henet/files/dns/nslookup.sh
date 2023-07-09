if expr "$(ls -l "$(command -v nslookup)")" : '.*-> .*busybox' >/dev/null
then
	echo 'busybox nslookup is not supported.' >&2
	exit 1
fi

LF='
'

find_zone_and_ns() {
	zone=${1:?}
	zone=${zone%.}

	while test -n "${zone}"
	do
		if ! nslookup -nosearch -class=IN -type=CNAME "${zone}" \
			| grep -q -F 'canonical name = '
		then
			# Only if not a CNAME
			name_servers=$(
				nslookup -nosearch -class=IN -type=NS "${zone}" \
				| sed -n -e 's/^.*[[:space:]]nameserver = \(.*\)$/\1/p')
			if test -n "${name_servers}"
			then
				break
			fi
		fi

		zone=$(expr "${zone}" : '[^.]\{1,\}\.\(.*\)$')
	done

	test -n "${zone}" || return 1
	ns=${name_servers%%${LF}*}
	ns=${ns%.}
	printf '%s@%s\n' "${zone}" "${ns}"
}

resolve_cnames() (
	domain=${1:?}
	domain=${domain%.}

	zone_and_ns=$(find_zone_and_ns "${domain}")
	ns=${zone_and_ns#*@}

	cname=$(
		nslookup -nosearch -norecurse -class=IN -type=CNAME "${domain}" "${ns}" \
		| sed -n -e 's/^.*[[:space:]]canonical name = \(.*\)$/\1/p')

	test -n "${cname}" && resolve_cnames "${cname}" || echo "${domain}"
)

dns_query() {
	nslookup -type="$2" -class=IN "$3" "$1" \
	| awk -v q="$3" '{ if (1==index($0, q)) { sub(/^.*= */, ""); print }}'
}
