ENV['RAILS_ENV'] ||= 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'fakeredis/rspec'

require 'aws-sdk-core'

avro_stub = File.read(File.expand_path('../support/user_was_created.avro', __FILE__))

Aws.config[:stub_responses] = true
Aws.config[:kinesis] = {
  stub_responses: {
    describe_stream: {
      stream_description: {
        stream_name: 'test_stream',
        stream_arn: '',
        has_more_shards: false,
        retention_period_hours: 24,
        enhanced_monitoring: [],
        stream_status: 'ACTIVE',
        shards: [
          {
            shard_id: 'abc123',
            hash_key_range: {
              starting_hash_key: '',
              ending_hash_key: ''
            },
            sequence_number_range: {
              starting_sequence_number: '1',
              ending_sequence_number: nil
            }
          },
          {
            shard_id: 'def456',
            hash_key_range: {
              starting_hash_key: '',
              ending_hash_key: ''
            },
            sequence_number_range: {
              starting_sequence_number: '1',
              ending_sequence_number: nil
            }
          }
        ]
      }
    },
    get_shard_iterator: {
      shard_iterator: 'ghi789'
    },
    get_records: {
      records: [
        { data: avro_stub, partition_key: '', sequence_number: '' }
      ],
      millis_behind_latest: 10,
      next_shard_iterator: 'jkl012'
    }
  }
}

unless ENV['DEBUG']
  require 'stream_reader'
  StreamReader.instance_eval do
    @logger = Logger.new(nil)
  end
end

RSpec.configure do |config|
  srand(Time.now.to_i)
  config.color = true
  config.seed ||= rand(1024)
end
