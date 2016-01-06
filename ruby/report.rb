require 'bundler'
Bundler.require

ses = Aws::SES::Client.new
cw  = Aws::CloudWatch::Client.new

quota = ses.get_send_quota

statistics        = ses.get_send_statistics.send_data_points.sort_by(&:timestamp).last(4)
delivery_attempts = statistics.map(&:delivery_attempts).inject(&:+)
bounces           = statistics.map(&:bounces).inject(&:+)
complaints        = statistics.map(&:complaints).inject(&:+)
rejects           = statistics.map(&:rejects).inject(&:+)

cw.put_metric_data(
  namespace: 'SES',
  metric_data: [
    {
      metric_name: 'QuotaUsageRate',
      value: quota.sent_last_24_hours / quota.max_24_hour_send * 100,
      unit: 'Percent'
    },
    {
      metric_name: 'BounceRate',
      value: bounces.to_f / delivery_attempts * 100,
      unit: 'Percent'
    },
    {
      metric_name: 'ComplaintRate',
      value: complaints.to_f / delivery_attempts * 100,
      unit: 'Percent'
    },
    {
      metric_name: 'RejectRate',
      value: rejects.to_f / delivery_attempts * 100,
      unit: 'Percent'
    }
  ]
)
