#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <KEY=VALUE configuration file>" >&2
  exit 64
fi
config_file=$1
if [ ! -r "$config_file" ]; then
  echo "ERROR: configuration file is not readable" >&2
  exit 66
fi

get_value() {
  local key=$1
  sed -n -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*(.*)[[:space:]]*$/\\1/p" "$config_file" | tail -n 1 | sed -E 's/^"(.*)"$/\1/'
}
failures=0
check() {
  local name=$1 result=$2
  if [ "$result" = ok ]; then printf 'OK: %s\n' "$name"; else printf 'ERROR: %s\n' "$name" >&2; failures=$((failures + 1)); fi
}

enabled=$(get_value ALIPAY_ENABLED)
app_id=$(get_value ALIPAY_APP_ID)
seller_id=$(get_value ALIPAY_SELLER_ID)
private_key=$(get_value ALIPAY_PRIVATE_KEY)
platform_key=$(get_value ALIPAY_PLATFORM_PUBLIC_KEY)
notify_url=$(get_value ALIPAY_NOTIFY_URL)
return_url=$(get_value ALIPAY_RETURN_URL)
min_topup=$(get_value ALIPAY_MIN_TOPUP)

check 'ALIPAY_ENABLED is explicitly true or false' "$( [[ "$enabled" =~ ^(true|false)$ ]] && echo ok || echo bad )"
check 'ALIPAY_APP_ID is a 16-digit numeric value' "$( [[ "$app_id" =~ ^[0-9]{16}$ ]] && echo ok || echo bad )"
check 'ALIPAY_SELLER_ID begins with 2088 and has 16 digits' "$( [[ "$seller_id" =~ ^2088[0-9]{12}$ ]] && echo ok || echo bad )"
check 'ALIPAY_PRIVATE_KEY is present and PEM-encoded' "$( [[ "$private_key" == *'BEGIN '*'PRIVATE KEY'* && "$private_key" == *'END '*'PRIVATE KEY'* ]] && echo ok || echo bad )"
check 'ALIPAY_PLATFORM_PUBLIC_KEY is present and PEM-encoded' "$( [[ "$platform_key" == *'BEGIN '*'PUBLIC KEY'* && "$platform_key" == *'END '*'PUBLIC KEY'* ]] && echo ok || echo bad )"
check 'ALIPAY_NOTIFY_URL uses public HTTPS' "$( [[ "$notify_url" =~ ^https:// && "$notify_url" != *127.0.0.1* && "$notify_url" != *localhost* && "$notify_url" != *://10.* && "$notify_url" != *://192.168.* ]] && echo ok || echo bad )"
check 'ALIPAY_RETURN_URL uses public HTTPS' "$( [[ "$return_url" =~ ^https:// && "$return_url" != *127.0.0.1* && "$return_url" != *localhost* && "$return_url" != *://10.* && "$return_url" != *://192.168.* ]] && echo ok || echo bad )"
check 'ALIPAY_MIN_TOPUP is at least 0.01' "$( awk -v amount="$min_topup" 'BEGIN { exit !(amount + 0 >= 0.01) }' && echo ok || echo bad )"

if [ "$failures" -gt 0 ]; then
  printf 'Validation failed: %d check(s). No credential values were printed.\n' "$failures" >&2
  exit 1
fi
echo 'Configuration structure is valid. This does not verify provider authorization or key pairing.'
