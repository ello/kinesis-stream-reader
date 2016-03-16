<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Kinesis Stream Reader Ruby Gem

This gem provides a ruby API to the Roshi backed 
[ello/streams](https://github.com/ello/streams) service.

[![Build Status](https://travis-ci.org/ello/kinesis-stream-reader.svg?branch=master)](https://travis-ci.org/ello/kinesis-stream-reader)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stream_service', github: 'ello/streams-client'
```

And then execute:

    $ bundle


## Usage

Add stream items to a stream:

```ruby

  item1 = StreamService::Item.from_post(
    post_id: 12345,
    user_id: "abc123",
    timestamp: DateTime.now - 2.minutes,
    is_repost: true
  )

  item2 = StreamService::Item.from_post(
    post_id: 67890,
    user_id: "def456",
    timestamp: DateTime.now - 2.minutes,
    is_repost: true
  )

  StreamService.add_items([item1, item2])

```
