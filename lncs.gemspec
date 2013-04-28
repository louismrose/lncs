lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'lncs/version'

Gem::Specification.new do |spec|
  spec.name        = 'lncs'
  spec.version     = LNCS::VERSION
  spec.licenses    = ['MIT']
  spec.authors     = ["Louis M. Rose"]
  spec.email       = ["louismrose@gmail.com"]
  spec.homepage    = "https://github.com/louismrose/lncs"
  spec.summary     = %q{A few tools for automating the preparation of a Springer LNCS volume}
  spec.description = %q{Automates the production of tables of contents and author indexes, and the arrangement of papers for a Springer LNCS volume.}

  spec.required_ruby_version     = '>= 1.8.7'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.files       = `git ls-files`.split($/)

  spec.executables   = %w(lncs)
  spec.require_paths = ["lib"]
end