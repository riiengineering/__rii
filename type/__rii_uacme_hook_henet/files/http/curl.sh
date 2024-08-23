http_post() {
	# usage: http_post url [-d post_data...]
	curl -sS "$@"
}
