require_relative 'lib/preferredpictures/version'

Gem::Specification.new do |spec|
  spec.name          = "preferredpictures"
  spec.version       = PreferredPictures::VERSION
  spec.authors       = ["Preferred Pictures"]
  spec.email         = ["contact@preferred.pictures"]

  spec.summary       = %q{PreferredPictures Ruby client library}
  spec.description   = %q{The PreferredPictures Ruby client library provides a convenient way to call the PreferredPictures API for applications written in Ruby.}
  spec.homepage      = "https://github.com/preferred-pictures/ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/preferred-pictures/ruby.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.2"
end
