require 'spec_helper'
require_relative '../../lib/stream_reader/avro_parser'

describe AvroParser do
  let(:data) { File.read(File.join(File.dirname(__FILE__), '..', 'support', 'user_was_created.avro')) }
  let(:seq_number) { 'asdf123' }
  let(:shard_id) { '1' }
  let(:parser) { described_class.new(data, seq_number, shard_id) }

  it 'parses an Avro message' do
    parser.each_with_schema_name do |record, opts|
      expect(opts[:schema_name]).to eq('UserWasCreated')
      expect(opts[:sequence_number]).to eq seq_number
      expect(opts[:raw_data]).to eq data
      expect(opts[:shard_id]).to eq shard_id
      expect(record).to eq({
        "id"=>"1",
        "username"=>"hello",
        "created_at"=>"2015-08-17T13:57:09-06:00",
        "email"=>"hello@example.com",
        "analytics_id"=>"123123"
      })
    end
  end
end
