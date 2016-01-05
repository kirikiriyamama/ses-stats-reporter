#!/bin/bash -e

put_metric_data() {
  metric_name=${1}
  value=${2}
  aws cloudwatch put-metric-data --namespace 'SES' --metric-name ${metric_name} --value ${value}
}

report_statistics() {
  set -- $(aws ses get-send-statistics | jq "`cat <<FILTER
.SendDataPoints | sort_by(.Timestamp)[-4:] |
  ([.[].DeliveryAttempts] | add),
  ([.[].Bounces] | add),
  ([.[].Complaints] | add),
  ([.[].Rejects] | add)
FILTER`")
  delivery_attempts=${1}
  bounces=${2}
  complaints=${3}
  rejects=${4}

  put_metric_data 'BounceRate' $(echo "scale=3; ${bounces} / ${delivery_attempts} * 100" | bc)
  put_metric_data 'ComplaintRate' $(echo "scale=3; ${complaints} / ${delivery_attempts} * 100" | bc)
  put_metric_data 'RejectRate' $(echo "scale=3; ${rejects} / ${delivery_attempts} * 100" | bc)
}

report_quota() {
  put_metric_data 'QuotaUsed' $(aws ses get-send-quota | jq '.SentLast24Hours / .Max24HourSend * 100')
}

report_statistics
report_quota
