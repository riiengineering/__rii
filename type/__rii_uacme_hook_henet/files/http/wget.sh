http_get_auth() {
	# usage: http_get_auth url user password

	# NOTE: this command is also used on OpenWrt where wget(1) is provided by uclient-fetch.
	wget -q -O- --user="${2:?}" --password="${3:?}" "${1:?}"
}
