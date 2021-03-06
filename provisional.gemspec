lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'provisional/version'

Gem::Specification.new do |spec|
  spec.name          = "provisional"
  spec.version       = Provisional::VERSION
  spec.authors       = ["Craig Buchek"]
  spec.email         = ["craig@boochtek.com"]

  spec.summary       = %q{Manage and provision server images}
  spec.description   = %q{Provisional is a tool to manage and provision server images, currently on Digital Ocean}
  spec.homepage      = "https://github.com/boochtek/provisional"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "gli", "~> 2.13"
  spec.add_dependency "droplet_kit", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.1"
  spec.add_development_dependency "cucumber", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "aruba", "~> 0.8.1"
end
