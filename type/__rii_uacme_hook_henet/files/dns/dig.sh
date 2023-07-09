LF='
'

find_zone_and_ns() (
	zone=${1:?}
	zone=${zone%.}

	while test -n "${zone}"
	do
		if test -z "$(dig "${zone}" CNAME IN +noall +short)"
		then
			# Only if not a CNAME
			name_servers=$(dig "${zone}" NS IN +noall +answer +short)
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

	cname=$(dig @"${ns}" "${domain}" CNAME IN +noall +authority +short)

	test -n "${cname}" && resolve_cnames "${cname}" || echo "${domain}"
)

dns_query() {
	dig @"$1" "$3" "$2" IN +noall +short
}
