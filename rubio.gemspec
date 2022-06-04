# frozen_string_literal: true

require_relative 'lib/rubio/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubio-radio'
  spec.version       = Rubio::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Rubio'
  spec.description   = 'Rubio'
  spec.homepage      = 'https://github.com/kojix2/rubio'
  spec.license       = 'MIT'

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = %w[rubio]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'glimmer-dsl-libui'
  spec.add_runtime_dependency 'matrix' # will be removed
end
