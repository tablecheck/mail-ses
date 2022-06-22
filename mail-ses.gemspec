Gem::Specification.new do |s|
  s.name        = 'mail-ses'
  s.version     = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  s.licenses    = ['MIT']
  s.summary     = 'Ruby Mail delivery method handler for Amazon SES'
  s.description = 'Ruby Mail delivery method handler for Amazon SES'
  s.authors     = ['Johnny Shields']
  s.email       = 'info@tablecheck.com'
  s.files       = Dir.glob('lib/**/*') + %w[VERSION CHANGELOG.md LICENSE README.md]
  s.test_files  = Dir.glob('spec/**/*')
  s.homepage    = 'https://github.com/tablecheck/mail-ses'

  s.add_dependency('aws-sdk-sesv2', '>= 1.27')
  s.add_dependency('mail', '>= 2.2.5')
  s.add_development_dependency('rake', '>= 1')
  s.add_development_dependency('rspec', '>= 3.8')
  s.add_development_dependency('rubocop', '~> 0.57.0')
  s.add_development_dependency('nokogiri')
end
