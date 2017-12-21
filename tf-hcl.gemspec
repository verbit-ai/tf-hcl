
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tf/hcl/version"

Gem::Specification.new do |spec|
  spec.name          = "tf-hcl"
  spec.version       = Tf::Hcl::VERSION
  spec.authors       = ["Adam Tistler"]
  spec.email         = ["atistler@datapipe.com"]

  spec.summary       = %q{A Terraform HCL parser/dumper written in Ruby}
  spec.description   = %q{A Terraform HCL parser.  Utilizes the Ruby Langauge Toolkit (RLTK) for lexing, parsing, and AST nodes.  Preserves comments and ordering (important for a config language)}
  spec.homepage      = "https://datapipe.github.net/Automation/tf-hcl"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_runtime_dependency "rltk"
end
