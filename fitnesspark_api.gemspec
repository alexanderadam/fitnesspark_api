# frozen_string_literal: true

require_relative 'lib/fitnesspark_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'fitnesspark_api'
  spec.version       = FitnessparkApi::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Alexander Adam']
  spec.email         = ['alexander.adam@vade.io']

  spec.summary       = 'Access Migros Fitnesspark data via Ruby'
  spec.description   = 'Access Migros Fitnesspark data via Ruby'
  spec.homepage      = 'https://github.com/alexanderadam/fitnesspark_api'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/alexanderadam/fitnesspark_api'
  spec.metadata['changelog_uri'] = 'https://github.com/alexanderadam/fitnesspark_api/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'oga'
  spec.add_dependency 'oj'
end
