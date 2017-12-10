# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yordi_tests"

Gem::Specification.new do |spec|
  spec.name          = "yordi_tests"
  spec.version       = YordiTests::VERSION
  spec.authors       = ["Brian OQR"]
  spec.email         = ["oqrbrian@gmail.com"]

  spec.summary       = "This is a CLI to run standalone or integrate with online YordiTests.com"
  spec.description   = "This is and alpha versiona nd under constant development, not yet stable"
  spec.homepage      = "https://www.yorditests.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
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

  spec.add_dependency 'thor'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'mini_magick', '~>4.8.0'


  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
