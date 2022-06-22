# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mail/ses/version'

Gem::Specification.new do |s|
  s.name        = 'mail-ses'
  s.version     = Mail::SES::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Ruby Mail delivery method handler for Amazon SES'
  s.description = 'Ruby Mail delivery method handler for Amazon SES'
  s.authors     = ['Johnny Shields']
  s.email       = 'info@tablecheck.com'
  s.files       = Dir.glob('lib/**/*') + %w[CHANGELOG.md LICENSE README.md]
  s.homepage    = 'https://github.com/tablecheck/mail-ses'
  s.required_ruby_version = '2.6.0'

  s.add_dependency('aws-sdk-sesv2', '>= 1.27')
  s.add_dependency('mail', '>= 2.2.5')
  s.add_development_dependency('nokogiri')
  s.add_development_dependency('rake', '>= 1')
  s.add_development_dependency('rspec', '>= 3.8')
  s.add_development_dependency('rubocop', '~> 1.30.1')

  s.metadata['rubygems_mfa_required'] = 'true'
end
