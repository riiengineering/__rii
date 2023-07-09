LF='
'

find_zone_and_ns() (
	zone=${1:?}
	zone=${zone%.}

	while test -n "${zone}"
	do
		if drill "${zone}" CNAME IN | awk '/[ \t]CNAME[ \t]/{rc=1}END{exit rc}'
		then
			# Only if not a CNAME
			name_servers=$(drill "${zone}" NS IN | awk '/^;; ANSWER SECTION:$/{p=1;next} !$0{p=0} p{ if (match($0, /[ \t]NS[ \t]+/)) print substr($0, RSTART+RLENGTH) }')
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
)

resolve_cnames() (
	domain=${1:?}
	domain=${domain%.}

	zone_and_ns=$(find_zone_and_ns "${domain}")
	ns=${zone_and_ns#*@}

	cname=$(drill "${domain}" @"${ns}" CNAME IN | awk '/^;; ANSWER SECTION:$/{p=1;next} !$0{p=0} p{ if (match($0, /[ \t]CNAME[ \t]+/)) print substr($0, RSTART+RLENGTH) }')

	test -n "${cname}" && resolve_cnames "${cname}" || echo "${domain}"
)

dns_query() {
	drill -Q "$3" @"$1" "$2" IN +noall +short
}
