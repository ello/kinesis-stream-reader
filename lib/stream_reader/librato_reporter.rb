require 'librato/metrics'

module LibratoReporter
  class << self
    def run!
      @client = Librato::Metrics::Client.new
      @client.authenticate(ENV['LIBRATO_USER'],
                           ENV['LIBRATO_TOKEN'])
      autosubmit_interval = Integer(ENV['LIBRATO_AUTOSUBMIT_INTERVAL'] || 30)
      @queue = Librato::Metrics::Queue.new(autosubmit_interval: autosubmit_interval,
                                           client: @client)
      add_listeners
    end

    private

    def add_listeners
      ActiveSupport::Notifications.subscribe('stream_reader.process_record') do |name, start, finish, id, payload|
        @queue.add "#{name}.duration": {
          value: (finish - start),
          source: "#{payload[:stream_name]}:#{payload[:prefix]}:#{payload[:shard_id]}" },
          "#{name}.latency": {
          value: payload[:ms_behind],
          source: "#{payload[:stream_name]}:#{payload[:prefix]}:#{payload[:shard_id]}" }
      end
    end
  end
end
