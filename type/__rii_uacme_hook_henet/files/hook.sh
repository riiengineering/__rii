#!/bin/sh
#
# 2023,2024 Dennis Camera (dennis.camera at riiengineering.ch)
#
# This file is part of the __rii_uacme_hook_henet skonfig type.
#
# __rii_uacme_hook_henet is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# __rii_uacme_hook_henet is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with __rii_uacme_hook_henet. If not, see <http://www.gnu.org/licenses/>.
#
set -e -u

#include $DNS_IMPL

#include $HTTP_IMPL

dnshenet_update_txt() {
	# usage: dnshenet_update_txt hostname password auth

	case ${1#_acme-challenge.}
	in
		(*[!A-Za-z0-9.-]*)
			printf '%s: is not a valid hostname (did you forget to punycode?)\n' "${1:?}" >&2
			return 2
			;;
	esac

	case ${3:?}
	in
		(*[!A-Za-z0-9.~_-]*)
			printf 'The auth token contains characters which would need to be urlencoded. This is not supported currently.\n' >&2
			return 2
			;;
	esac

	response=$(http_get_auth \
		"https://dyn.dns.he.net/nic/update?hostname=${1:?}&txt=${3:?}" \
		"${1:?}" \
		"${2:?}")

	case ${response}
	in
		(good*)
			echo 'good'
			return 0
			;;
		(badauth)
			echo 'badauth: Authentication failed.' >&2
			return 1
			;;
		(nochg*)
			printf '%s\n' "${response}"
			return 0
			;;
		(*)
			printf '%s\n' "${response}"
			return 1
			;;
	esac
}


case $#
in
	(5)
		method=$1
		type=$2
		ident=$3
		token=$4
		auth=$5
		;;
	(*)
		printf 'usage: %s method type ident token auth\n' "$0" >&2
		exit 85
		;;
esac

case ${method}
in
	(begin)
		case ${type}
		in
			(http-01)
				# not supported
				exit 1
				;;
			(dns-01)
				hostname=$(resolve_cnames "_acme-challenge.${ident}")

				dnshenet_update_txt "${hostname}" %%PASSWORD%% "${auth}" || exit

				henet_server=ns5.he.net
				i=0
				while test $((i)) -lt 10
				do
					case $(dns_query "${henet_server}" TXT "${hostname}")
					in
						("\"${auth}\"")
							echo 'DNS was updated.'
							break
							;;
						(*)
							printf '%s did not respond with correct token. ' "${henet_server}"
							;;
					esac

					: $((i += 1))

					printf 're-trying in 30s.\n'
					sleep 30
				done
				;;
			(tls-alpn-01)
				# not supported
				exit 1
				;;
			(*)
				# invalid type
				printf 'error: invalid type: %s\n' "${type}" >&2
				exit 2
				;;
		esac
		;;
	(done|failed)
		case ${type}
		in
			(http-01)
				# not supported
				exit 1
				;;
			(dns-01)
				exit 0
				;;
			(tls-alpn-01)
				# not supported
				exit 1
				;;
			(*)
				# invalid type
				printf 'error: invalid type: %s\n' "${type}" >&2
				exit 2
				;;
		esac
		;;
	(*)
		printf 'error: invalid method: %s\n' "${method}" >&2
		exit 2
		;;
esac
