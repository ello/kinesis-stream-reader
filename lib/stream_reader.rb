require 'stream_helper'
require 'shard_reader'

class StreamReader
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end

  # Assume only one shard for now
  DEFAULT_BATCH_SIZE = 100

  def initialize(stream_name:, prefix: '', client: Aws::Kinesis::Client.new)
    @stream_name = stream_name
    @prefix      = prefix
    @logger      = StreamReader.logger
    @client      = client

    # Threads raise exceptions to main process immediately, not on join.
    Thread.abort_on_exception = true

    trap('SIGTERM') do
      puts 'Caught SIGTERM, exiting...'
      stop!
    end
  end

  def run!(batch_size: DEFAULT_BATCH_SIZE, join: true, &block)
    LibratoReporter.run! if send_to_librato?

    @runners = []
    each_shard do |shard_id|
      @runners << spawn_reader_for_shard(shard_id, batch_size, &block)
    end

    join! if join
  rescue => e
    @logger.error "Caught exception: #{e}"
    # Prevent an infinite loop if another exception is triggered exiting another thread
    unless @exiting
      @logger.error "Stopping shard readers..."
      @exiting = true
      stop!
    end
    # Now re-raise, stopping process (or getting caught in implementation)
    raise e
  end

  def join!
    @runners.map(&:join)
  end

  def stop!
    @runners.map(&:stop_processing!)
    join!
  end

  private

  def spawn_reader_for_shard(shard_id, batch_size, &block)
    ShardReader.new(stream_name: @stream_name,
                    tracker_prefix: @prefix,
                    shard_id: shard_id,
                    batch_size: batch_size,
                    logger: @logger,
                    client: @client).tap { |sr| sr.run(&block) }
  end

  def each_shard
    resp = @client.describe_stream(stream_name: @stream_name)
    resp.stream_description.shards.each do |shard|
      yield shard.shard_id
    end
  end

  def send_to_librato?
    !!(ENV['LIBRATO_USER'] && ENV['LIBRATO_TOKEN'])
  end
end
