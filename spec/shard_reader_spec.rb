require 'spec_helper'
require_relative '../lib/shard_reader'
require 'logger'

describe ShardReader do
  describe 'executing a runner' do
    let(:reader) do
      ShardReader.new(stream_name: 'test_stream',
                      tracker_prefix: 'test-tracker',
                      shard_id: 'abc123',
                      batch_size: 1,
                      logger: StreamReader.logger,
                      client: Aws::Kinesis::Client.new)
    end

    it 'runs a block for each record returned' do
      stub_processor = double
      expect(stub_processor).to receive(:process).at_least(:once)
      reader.run { |record| stub_processor.process }
      sleep 3
      reader.stop_processing!
      reader.join
    end
  end
end
