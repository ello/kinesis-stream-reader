require 'stream_helper'

class StreamReader
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end

  # Assume only one shard for now
  DEFAULT_BATCH_SIZE = 100

  def initialize(stream_name:, prefix: '')
    @stream_name = stream_name
    @prefix      = prefix
    @tracker     = SequenceNumberTracker.new(key_prefix: [ stream_name, prefix ].compact.join('-'))
    @logger      = StreamReader.logger
    trap('SIGTERM') { @stop_processing = true; puts 'Exiting...' }
  end

  attr_reader :stop_processing

  def run!(batch_size: DEFAULT_BATCH_SIZE, &block)
    LibratoReporter.run! if send_to_librato?

    # Locate a shard id to iterate through - we only have one for now
    loop do
      break if stop_processing
      begin
        iterator_opts = { stream_name: @stream_name, shard_id: shard_id }
        if seq = @tracker.last_sequence_number
          iterator_opts[:shard_iterator_type] = 'AFTER_SEQUENCE_NUMBER'
          iterator_opts[:starting_sequence_number] = seq
        else
          iterator_opts[:shard_iterator_type] = 'TRIM_HORIZON'
        end
        @logger.debug "Getting shard iterator for #{@stream_name} / #{seq}"
        resp = client.get_shard_iterator(iterator_opts)
        shard_iterator = resp.shard_iterator

        # Iterate!
        loop do
          break if stop_processing
          sleep 1
          @logger.debug "Getting records for #{shard_iterator}"
          resp = client.get_records({
            shard_iterator: shard_iterator,
            limit: batch_size,
          })

          resp.records.each do |record|
            ActiveSupport::Notifications.instrument('stream_reader.process_record',
                                                    stream_name: @stream_name,
                                                    prefix: @prefix,
                                                    shard_id: shard_id,
                                                    ms_behind: resp.millis_behind_latest) do
              AvroParser.new(record.data).each_with_schema_name(&block)
              @tracker.last_sequence_number = record.sequence_number
            end
          end

          shard_iterator = resp.next_shard_iterator
        end

      rescue Aws::Kinesis::Errors::ExpiredIteratorException
        @logger.debug "Iterator expired! Fetching a new one."
      end
    end
  end

  private

  def client
    @client ||= Aws::Kinesis::Client.new
  end

  def shard_id
    @shard_id ||= begin
                    resp = client.describe_stream(stream_name: @stream_name, limit: 1)
                    resp.stream_description.shards[0].shard_id
                  end
  end

  def send_to_librato?
    !!(ENV['LIBRATO_USER'] && ENV['LIBRATO_TOKEN'])
  end
end
