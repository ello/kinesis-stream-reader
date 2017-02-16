require 'spec_helper'
require_relative '../lib/stream_reader'
require 'logger'

describe StreamReader do
  it 'has a logger' do
    expect(described_class.logger).to be_a(Logger)
  end

  describe 'spawning runner threads' do
    let(:client) { Aws::Kinesis::Client.new }
    let(:reader) { StreamReader.new(stream_name: 'test_stream', client: client) }

    it 'spawns a ShardReader for each shard returned' do
      allow_any_instance_of(ShardReader).to receive(:run).and_return(Thread.new { })
      expect(ShardReader).to receive(:new).twice.and_call_original
      reader.run! do
        # No-op
      end
    end

    it 'starts and stops gracefully' do
      stub_processor = double
      expect(stub_processor).to receive(:process).twice
      reader.run!(join: false) { |record| stub_processor.process }
      sleep 1
      reader.stop!
    end

    it 'handles errors gracefully' do
      expect { reader.run! { |record| raise 'boom' } }.to raise_error(StandardError)
    end
  end
end
