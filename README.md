# SES Stats Reporter

Scripts for monitoring hourly stats of SES. They get stats from SES, and then send the following values to CloudWatch: Quota Usage Rate, Bounce Rate, Complaint Rate and Reject Rate. Now, there are three implementations: Bash, Ruby and JavaScript (For AWS Lambda).

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

### JavaScript

```sh
$ cd js
$ npm install
$ zip -r ses-stats-reporter.zip index.js node_modules
```

Then, upload the zip file `ses-stats-reporter.zip`.

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
