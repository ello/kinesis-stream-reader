# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/stream_reader/version'

Gem::Specification.new do |spec|
  spec.name          = 'kinesis_stream_reader'
  spec.version       = StreamReader::VERSION
  spec.authors       = ['Justin-Holmes']
  spec.email         = ['justin.ryan.holmes@icloud.com']

  spec.summary       = %q{Ruby interface for reading Kinesis streams}
  spec.homepage      = 'https://github.com/ello/kinesis-stream-reader'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'avro'
  spec.add_dependency 'aws-sdk-core'
  spec.add_dependency 'redis'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fakeredis'
  spec.add_development_dependency 'pry'
end

