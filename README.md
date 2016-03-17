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

`$ bundle`

## Environment Variables

Set up your AWS keys:
 
* `AWS_REGION` 
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

A Redis server is required to help keep track of the reader's location within the Kinesis stream:
  
`REDIS_URL`

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

Run the stream reader. It will grab data matching the given `stream_name`:
 
```ruby
stream.run! do |record, kind|
  DoSomethingFromStream.perform(record: record, kind: kind)
end
```


## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ello/stream_service.

## License
Streams is released under the [MIT License](blob/master/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
