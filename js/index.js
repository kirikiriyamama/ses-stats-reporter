var aws = require('aws-sdk');

var ses = new aws.SES();
var cw  = new aws.CloudWatch();

exports.handler = function(event, context) {
  ses.getSendQuota(function(err, data) {
    if (err) {
      console.log(err);
      context.fail(err.message);
    }
    var quota = data;

    ses.getSendStatistics(function(err, data) {
      if (err) {
        console.log(err);
        context.fail(err.message);
      }
      var statistics = data.SendDataPoints.sort(function(a, b) {
        return a.Timestamp > b.Timestamp ? 1 : -1;
      }).slice(-4);

      var aggregate = function(key) {
        return statistics.map(function(statistic) {
          return statistic[key];
        }).reduce(function(previous, current) {
          return previous + current;
        });
      };
      var deliveryAttempts = aggregate('DeliveryAttempts');
      var bounces          = aggregate('Bounces');
      var complaints       = aggregate('Complaints');
      var rejects          = aggregate('Rejects');

      cw.putMetricData({
        Namespace: 'SES',
        MetricData: [
          {
            MetricName: 'QuotaUsageRate',
            Value: quota.SentLast24Hours / quota.Max24HourSend * 100,
            Unit: 'Percent'
          },
          {
            MetricName: 'BounceRate',
            Value: bounces / deliveryAttempts * 100,
            Unit: 'Percent'
          },
          {
            MetricName: 'ComplaintRate',
            Value: complaints / deliveryAttempts * 100,
            Unit: 'Percent'
          },
          {
            MetricName: 'RejectRate',
            Value: rejects / deliveryAttempts * 100,
            Unit: 'Percent'
          }
        ]
      }, function(err, data) {
        if (err) {
          console.log(err);
          context.fail(err.message);
        } else {
          context.succeed();
        }
      });
    });
  });
};
