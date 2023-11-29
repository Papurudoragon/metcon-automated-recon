#!/bin/bash
PROGS='\033[01;91m'
TEXTS='\033[01;90m'
RESET='\033[00m'
DASHES="------------------------------------"

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
# source ./src/config.sh

# Dependencies: htmlq, html-to-csv
# cargo install htmlq
# pip install html-to-csv

howitdone() {
  cat <<EOF
  relations, Bash Things with Bash and Things
  
  Usage: $(basename "${BASH_SOURCE[0]}") -a aa -t TARGET [-h]

  Required options:
    -d,  --domain   Something domain

  Helpful options:
    -h,  --help     Print this help and exit
    -v,  --verbose  Script Debug

EOF
  exit
}
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}
msg() {
  echo >&2 -e "${1-}"
}
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}
parse_params() {
  CURRDIR=$(pwd)
  # default values of variables set from params
  if [[ "$#" -eq 0 ]]; then
    howitdone
    exit
  fi
  while :; do
    case "${1-}" in
    -h | --help) howitdone ;;
    -v | --verbose) set -x ;;
    -d | --domain)
      DOMAIN="${2-}"
      export DOMAIN
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${DOMAIN-}" ]] && die "Missing required parameter: -d | --domain"

  return 0
}
parse_params "$@"

mkdir -p "$CURRDIR/$DOMAIN/logs/"
#https://builtwith.com/redirects/fisglobal.com
# /relationships:  Connected Websites:
# /company: Associated Domains, Tag History

echo -e "${TEXTS}Domain    : ${PROGS}$DOMAIN${RESET}"
echo -e "${TEXTS}Relations : ${PROGS}https://builtwith.com/relationships/$DOMAIN${RESET}"
echo -e "${TEXTS}Company   : ${PROGS}https://builtwith.com/company/$DOMAIN${RESET}\n"

curl -Lks "https://builtwith.com/company/$DOMAIN" -o "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-company.html"
if [[ -s "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-company.html" ]]; then
  htmlq -f "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-company.html" -a href a | grep "/detailed/" | sort -fu | sed 's#/detailed/##g' >"$CURRDIR/$DOMAIN/company-associated-domains.txt"
fi

curl -ks "https://builtwith.com/relationships/$DOMAIN" -o "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-relationships.html"
if [[ -s "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-relationships.html" ]]; then
  htmlq -f "$CURRDIR/$DOMAIN/logs/$DOMAIN-builtwith-relationships.html" -a href a | grep '/relationships/' >"$CURRDIR/$DOMAIN/logs/urls-relationships.txt"
  grep '/relationships/tag/' "$CURRDIR/$DOMAIN/logs/urls-relationships.txt" >"$CURRDIR/$DOMAIN/logs/urls-tag-history.txt"
  grep '/relationships/' "$CURRDIR/$DOMAIN/logs/urls-relationships.txt" | grep -v '/tag/' | awk -F "/" '{print $NF}' >"$CURRDIR/$DOMAIN/connected-websites.txt"
  if [[ -s "$CURRDIR/$DOMAIN/logs/urls-tag-history.txt" ]]; then
    for TAGURL in $(cat "$CURRDIR/$DOMAIN/logs/urls-tag-history.txt"); do
      TAG=$(echo $TAGURL | awk -F "/" '{print $NF}')
      curl -ks -o "$CURRDIR/$DOMAIN/logs/$TAG-history.html" "$TAGURL"
      if [[ -s "$CURRDIR/$DOMAIN/logs/$TAG-history.html" ]]; then
        html2csv "$CURRDIR/$DOMAIN/logs/$TAG-history.html" | sed 1d | cut -d, -f1 | anew -q "$CURRDIR/$DOMAIN/tag-domain-history.txt" &>/dev/null
        htmlq -f "$CURRDIR/$DOMAIN/logs/$TAG-history.html" -a href a | grep relations | awk -F '/' '{print $3}' | sort -fu >"$CURRDIR/$DOMAIN/logs/$TAG-history.txt"
      fi
    done
  fi
fi

if [[ -s "$CURRDIR/$DOMAIN/tag-domain-history.txt" ]]; then
  sort -fu "$CURRDIR/$DOMAIN/tag-domain-history.txt" >"$CURRDIR/$DOMAIN/tag-domain-history.txt.tmp"
  mv "$CURRDIR/$DOMAIN/tag-domain-history.txt.tmp" "$CURRDIR/$DOMAIN/tag-domain-history.txt"
  echo -e "  => ${TEXTS}Company - Tag Domain History : ${PROGS}$DOMAIN/tag-domain-history.txt${RESET}"
fi
if [[ -s "$CURRDIR/$DOMAIN/company-associated-domains.txt" ]]; then
  sort -fu "$CURRDIR/$DOMAIN/company-associated-domains.txt" >"$CURRDIR/$DOMAIN/company-associated-domains.txt.tmp"
  mv "$CURRDIR/$DOMAIN/company-associated-domains.txt.tmp" "$CURRDIR/$DOMAIN/company-associated-domains.txt"
  echo -e "  => ${TEXTS}Company - Associated Domains : ${PROGS}$DOMAIN/company-associated-domains.txt${RESET}"
fi
if [[ -s "$CURRDIR/$DOMAIN/connected-websites.txt" ]]; then
  sort -fu "$CURRDIR/$DOMAIN/connected-websites.txt" >"$CURRDIR/$DOMAIN/connected-websites.txt.tmp"
  mv "$CURRDIR/$DOMAIN/connected-websites.txt.tmp" "$CURRDIR/$DOMAIN/connected-websites.txt"
  echo -e "  => ${TEXTS}Related - Connected Websites : ${PROGS}$DOMAIN/connected-websites.txt${RESET}"
fi

if compgen -G $CURRDIR/$DOMAIN/logs/*.html >/dev/null; then
  rm $CURRDIR/$DOMAIN/logs/*.html
fi