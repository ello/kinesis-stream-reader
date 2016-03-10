require 'spec_helper'
require_relative '../../lib/stream_reader/avro_parser'

describe AvroParser do
  let(:data) { File.read(File.join(File.dirname(__FILE__), '..', 'support', 'user_was_created.avro')) }
  let(:parser) { described_class.new(data) }

  it 'parses an Avro message' do
    parser.each_with_schema_name do |record, schema_name|
      expect(schema_name).to eq('UserWasCreated')
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
