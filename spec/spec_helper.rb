ENV['RAILS_ENV'] ||= 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'stream_reader'
require 'pry'
require 'fakeredis/rspec'

RSpec.configure do |config|
  config.color = true
end
