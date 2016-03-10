require 'spec_helper'
require_relative '../lib/stream_reader'
require 'logger'

describe StreamReader do
  it 'has a logger' do
    expect(described_class.logger).to be_a(Logger)
  end
end
