require 'redis'

class SequenceNumberTracker
  def initialize(key_prefix:, redis_url: ENV['REDIS_URL'], key: 'kinesis-last-seq')
    uri    = URI.parse(redis_url || 'redis://localhost:6379')
    @redis = Redis.new(url: uri)
    @key   = "#{key_prefix}-#{key}"
  end

  def last_sequence_number
    @redis.get(@key)
  end

  def last_sequence_number=(value)
    @redis.set(@key, value)
  end
end
