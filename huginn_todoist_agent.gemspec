# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "huginn_todoist_agent"
  spec.version       = '0.2'
  spec.authors       = ["Stefan Siegl"]
  spec.email         = ["stesie@brokenpipe.de"]

  spec.summary       = %q{Huginn agent to add items to your Todoist.}
  spec.description   = %q{The Todoist Agent will create one item on your Todoist for every Huginn event it receives.}

  spec.homepage      = "https://github.com/stesie/huginn_todoist_agent"

  spec.license       = "MIT"


  spec.files         = Dir['LICENSE.txt', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir['spec/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "huginn_agent"
  spec.add_runtime_dependency 'ruby-todoist-api', '~> 0.3'
end
