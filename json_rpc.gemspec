require_relative 'lib/json_rpc/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_rpc'
  spec.version       = JsonRpc::VERSION
  spec.authors       = ['Tobias Bühlmann']
  spec.email         = ['tobias@xn--bhlmann-n2a.de']
  spec.summary       = 'JSON RPC 2.0 Rack Application Builder Library.'
  spec.description   = 'json_rpc lets you build JSON RPC 2.0 aware Rack Applications.'
  spec.homepage      = 'https://github.com/tbuehlmann/json_rpc'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'pry', '0.10.1'
end
