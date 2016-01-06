# SES Stats Reporter

Scripts for monitoring hourly stats of SES. They get stats from SES, and then send the following values to CloudWatch: Quota Usage Rate, Bounce Rate, Complaiant Rate and Reject Rate. Now, there are two implementations: Bash and Ruby.

## Usage

### Bash

```sh
$ bash/report.sh
```

### Ruby

```sh
$ cd ruby
$ bundle install
$ ruby report.rb
```

## Required permissions

```js
{
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "CloudWatch:PutMetricData"
    },
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ses:GetSendQuota",
        "ses:GetSendStatistics"
      ]
    }
  ]
}
```
