require 'spec_helper'
require_relative '../../lib/stream_reader/sequence_number_tracker'

describe SequenceNumberTracker do
  let(:tracker) { described_class.new(key_prefix: 'test-key')}
  let(:tracker2) { described_class.new(key_prefix: 'test-key')}
  let(:other_tracker) { described_class.new(key_prefix: 'other-test-key')}

  it 'initially has a nil sequence number' do
    expect(tracker.last_sequence_number).to be_nil
  end

  it 'stores the last saved value for the sequence number' do
    tracker.last_sequence_number = '1000'
    expect(tracker.last_sequence_number).to eq('1000')
  end

  it 'tracks the same value across individual tracker instances with the same key/prefix' do
    tracker.last_sequence_number = '1000'
    expect(tracker2.last_sequence_number).to eq('1000')
  end

  it 'does not track the same value across individual tracker instances with different keys/prefixes' do
    tracker.last_sequence_number = '1000'
    expect(other_tracker.last_sequence_number).to be_nil
  end
end
