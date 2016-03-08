require 'spec_helper'

describe StreamReader do
  it 'has a logger' do
    expect(described_class.logger).to be_a(Logger)
  end
end
