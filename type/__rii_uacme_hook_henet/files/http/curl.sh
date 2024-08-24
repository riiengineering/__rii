http_get_auth() {
	# usage: http_get_auth url user password
	curl -sS -u "${2:?}:${3:?}" "${1:?}"
}
