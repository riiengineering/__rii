http_post() {
	# usage: http_post url [-d post_data...]

	__http_post_url=$1
	shift

	while test $# -gt 0
	do
		case $1,$2
		in
			(-d,?*)
				__http_post_data=${__http_post_data-}${__http_post_data:+&}${2%%=*}="${2#*=}"
				shift 2
				;;
			(*)
				# invalid option
				shift
				;;
		esac
	done

	set -- ${__http_post_data:+--post-data="${__http_post_data}"} "${__http_post_url}"
	unset -v __http_post_data __http_post_url

	# NOTE: this command is also used on OpenWrt where wget(1) is provided by uclient-fetch.
	wget -q -O- "$@"
}
