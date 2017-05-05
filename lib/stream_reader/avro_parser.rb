require 'avro'

class AvroParser
  def initialize(data, seq_number, shard_id)
    @data       = data
    @seq_number = seq_number
    @shard_id   = shard_id
  end

  def each_with_schema_name
    buffer = StringIO.new(@data)
    reader = Avro::DataFile::Reader.new(buffer, Avro::IO::DatumReader.new)
    reader.each do |record|
      if reader.datum_reader.readers_schema.class == Avro::Schema::RecordSchema
        schema_name = reader.datum_reader.readers_schema.name
      else
        schema_name = reader.datum_reader.readers_schema.schemas.last.name
      end
      yield record, { schema_name: schema_name, raw_data: buffer.string, sequence_number: @seq_number, shard_id: @shard_id }
    end
  end
end

