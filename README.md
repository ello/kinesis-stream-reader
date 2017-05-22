<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Kinesis Stream Reader Ruby Gem

[Kinesis](http://docs.aws.amazon.com/kinesis/latest/dev/introduction.html) is a platform for streaming data on AWS, offering powerful services to make it easy to load and analyze streaming data, and also providing the ability for you to build custom streaming data applications for specialized needs.
This gem is a helpful utility for parsing data from a Kinesis stream.


[![Build Status](https://travis-ci.org/ello/kinesis-stream-reader.svg?branch=master)](https://travis-ci.org/ello/kinesis-stream-reader)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kinesis-stream-reader', github: 'ello/kinesis-stream-reader', require: 'stream_reader'
```

And then execute:

    $ bundle

## Environment Variables

Set up your AWS keys:
 
* `AWS_REGION` 
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

A Redis server is required to help keep track of the reader's location within the Kinesis stream:
  
* `REDIS_URL`

Add the Kinesis stream name and prefix:

* `KINESIS_STREAM_NAME`
* `KINESIS_STREAM_NAME_PREFIX`

## Usage
This gem assumes that you're storing your data in Kinesis with [Avro](https://rubygems.org/gems/avro) format. More documentation on Avro can be found here: [http://avro.apache.org/](http://avro.apache.org/)  

Configure the stream reader to read from a particular stream:

```ruby
stream = StreamReader.new(
  stream_name: ENV['KINESIS_STREAM_NAME'],
  prefix:      ENV['KINESIS_STREAM_PREFIX'] || ''
)
```

Run the stream reader.
```ruby
stream.run! do |record, opts|
  DoSomethingFromStream.perform(record: record, kind: opts[:schema_name])
end
```
It will grab data matching the given `stream_name`, where `record` is the parsed data and `opts` is a hash containing:
* `schema_name` - the name of the event/schema stored in Kinesis
* `raw_data` - the raw, unparsed avro data
* `sequence_number` - the sequence number of the Kinesis event
* `shard_id` - the shard_id that the event is being processed on


As of version 0.2.0, a stream with multiple shards will have a thread spawned per-shard to process the records from that shard. You should ensure that whatever happens in your processing block is thread-safe, particularly as it pertains to using external resources. For instance, you'll likely want to use `ActiveRecord::Base.with_connection` to wrap any database calls.


## Upgrading 
Version 0.2.0 introduced a threading model for spawning multiple readers to service streams with more than one shard. As a result of that change, the sequence number tracker key structure changed as well, to be able to track the position of a reader for each shard. When upgrading, you'll need to do one of two things:

- If your processing blocks are idempotent and fast, you can simply do nothing and let the processors re-process old data starting from the `TRIM_HORIZON`.
- Otherwise, you can manually obtain the `shard_id` value from a `DescribeStream` call and move the value of the last processed sequence number to a new key in Redis. You'll need to stop your workers while doing this. This will avoid re-processing the same records multiple times.

### Librato Telemetry
If you specify the `LIBRATO_USER` and `LIBRATO_TOKEN` environment variables, shard processor stats will be periodically reported to Librato (with the metrics `stream_reader.process_record.duration` and `stream_reader.process_record.latency` and a custom source that identifies the prefix and shard id). It is highly recommended that you monitor at least the latency metric to ensure that your processors do not fall so far behind that data is [dropped from the stream](http://docs.aws.amazon.com/streams/latest/dev/kinesis-extended-retention.html) before it can be processed. If you monitor that metric, you should also have a "dead man's switch"-type metric that alerts if it stops reporting.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ello/kinesis-stream-reader.

## License
Released under the [MIT License](/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
