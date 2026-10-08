#!/bin/bash

function count() {
	local path="db/${1}"

	if [[ ! "${1}" =~ \.json$ ]]; then
		wc -l "${path}" | awk '{print $1}'
		return 0
	fi

	local prop
	case "${1}" in
		common-web-attacks* )
			prop="filters"
			;;
		cves* )
			prop="templates"
			;;
	esac
	jq -r ".${prop} | length" "${path}"
}

CWA_count=$(count "common-web-attacks.json")
CVEs_count=$(count "cves.json")
BadIP_count=$(count "bad-ip-addresses.txt")
BadRef_count=$(count "bad-referrers.txt")
BadCrawl_count=$(count "bad-crawlers.txt")
DirBrute_count=$(count "directory-bruteforces.txt")
total_count=$((CWA_count + CVEs_count + BadIP_count + BadRef_count + BadCrawl_count + DirBrute_count))

STATS_TABLE=${STATS_TABLE_TMPL}
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{CWA_count}}/${CWA_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{CVEs_count}}/${CVEs_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{BadIP_count}}/${BadIP_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{BadRef_count}}/${BadRef_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{BadCrawl_count}}/${BadCrawl_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{DirBrute_count}}/${DirBrute_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed "s/{{total_count}}/${total_count}/")
STATS_TABLE=$(echo "${STATS_TABLE}" | sed ':a;N;$!ba;s/\n/\\n/g')

README_TMPL=$(cat .README.tmpl)
README_TMPL=$(echo "${README_TMPL}" | sed "s/{{stats}}/${STATS_TABLE}/") # it doesn't work
README_TMPL=$(echo "${README_TMPL}" | sed "s/{{updated_date}}/$(date)/")

echo "${README_TMPL}"