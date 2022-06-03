# frozen_string_literal: true

require_relative 'lib/radio/version'

Gem::Specification.new do |spec|
  spec.name          = 'radio'
  spec.version       = Radio::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Radio'
  spec.description   = 'Radio'
  spec.homepage      = 'https://github.com/kojix2/radio'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = %w[radio]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'glimmer-dsl-libui'
  spec.add_runtime_dependency 'matrix' # will be removed
end
