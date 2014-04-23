lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
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

  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.files       = `git ls-files`.split($/).reject { |f| f.start_with? "examples/" }
  spec.executables   = %w(lncs)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "json", "~> 1.7"
  spec.add_dependency "thor", "~> 0.18"
  spec.add_dependency "zip", "~> 2.0"
  spec.add_dependency "pdf-reader", "~> 1.3"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end