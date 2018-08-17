require 'rubygems'
require 'bundler/setup'
require 'rspec'

Bundler.setup

require 'mail-ses'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random

  Kernel.srand config.seed
end
