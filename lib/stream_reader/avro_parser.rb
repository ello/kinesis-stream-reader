require 'avro'

class AvroParser
  def initialize(data)
    @data = data
  end

  def each_with_schema_name
    buffer = StringIO.new(@data)
    reader = Avro::DataFile::Reader.new(buffer, Avro::IO::DatumReader.new)
    reader.each do |record|
      if reader.datum_reader.readers_schema.class == Avro::Schema::RecordSchema
        schema_name = reader.datum_reader.readers_schema.name
      else
        reader.datum_reader.readers_schema.schemas.last.name
      end
      yield record, schema_name
    end
  end
end

