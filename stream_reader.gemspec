# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/stream_reader/version'

Gem::Specification.new do |spec|
  spec.name          = 'kinesis-stream-reader'
  spec.version       = StreamReader::VERSION
  spec.authors       = ['Justin-Holmes']
  spec.email         = ['justin.ryan.holmes@icloud.com']

  spec.summary       = %q{Ruby interface for reading AWS Kinesis streams}
  spec.homepage      = 'https://github.com/ello/kinesis-stream-reader'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'avro', '~> 1.7.7'
  spec.add_dependency 'aws-sdk-core', '~> 2.2.26'
  spec.add_dependency 'redis', '~> 3.2.2'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'librato-metrics'
  spec.add_dependency 'faraday', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fakeredis'
  spec.add_development_dependency 'pry'
end
