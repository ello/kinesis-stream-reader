require 'librato/metrics'
require 'thread'

module LibratoReporter
  class << self
    def run!
      @client = Librato::Metrics::Client.new
      @client.authenticate(ENV['LIBRATO_USER'],
                           ENV['LIBRATO_TOKEN'])
      autosubmit_interval = Integer(ENV['LIBRATO_AUTOSUBMIT_INTERVAL'] || 60)
      autosubmit_count    = Integer(ENV['LIBRATO_AUTOSUBMIT_COUNT'] || 10000)
      @aggregator = Librato::Metrics::Aggregator.new(autosubmit_interval: autosubmit_interval,
                                                     autosubmit_count: autosubmit_count,
                                                     client: @client)
      @mutex = Mutex.new
      add_listeners
    end

    private

    def add_listeners
      ActiveSupport::Notifications.subscribe('stream_reader.process_record') do |name, start, finish, id, payload|
        @mutex.synchronize do
          @aggregator.add "#{name}.duration": {
            value: (finish - start),
            source: "#{payload[:stream_name]}:#{payload[:prefix]}:#{payload[:shard_id]}" },
            "#{name}.latency": {
            value: payload[:ms_behind],
            source: "#{payload[:stream_name]}:#{payload[:prefix]}:#{payload[:shard_id]}" }
        end
      end
    end
  end
end
