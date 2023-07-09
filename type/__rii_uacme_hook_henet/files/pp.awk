#!/usr/bin/awk -f

function error(msg) {
	printf "%s:%u: %s" ORS, FILENAME, FNR, msg | "cat >&2"
}

"#include" == $1 {
	if ($2 ~ /^\$/) {
		include_file = ENVIRON[substr($2, 2)]
		if (include_file) {
			while (0 < (getline <include_file))
				print
		} else {
			error("no include file found for " $2)
		}
	} else {
		error("unsupported include")
	}

	next
}

{
	while (match($0, /%%[A-Z0-9_]+%%/)) {
		envvar = substr($0, RSTART + 2, RLENGTH - 4)
		sub("%%" envvar "%%", ENVIRON["SCR_" envvar])
	}
	print
}
