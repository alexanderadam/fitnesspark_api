# frozen_string_literal: true

require 'bundler/setup'
require 'fitnesspark_api'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.join('spec', 'vcr_cassettes')
  config.hook_into :webmock
  config.default_cassette_options = { record: :new_episodes }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    # c.treat_symbols_as_metadata_keys_with_true_values = true
  end

  config.around(:each) do |example|
    vcr_tag = example.metadata[:vcr]

    if vcr_tag == false
      VCR.turned_off(&example)
    else
      options = vcr_tag.is_a?(Hash) ? vcr_tag : {}
      path_data = [example.metadata[:description]]
      parent = example.example_group
      while parent != RSpec::ExampleGroups && parent.respond_to?(:parent)
        path_data << parent.metadata[:description]
        parent = parent.parent
      end

      name = path_data.map do |str|
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .gsub(/\./, '')
           .gsub(%r{[^\w/]+}, '_')
           .gsub(%r{/$}, '')
      end

      VCR.use_cassette(name.reverse.join('/'), options, &example)
    end
  end
end
