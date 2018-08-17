Gem::Specification.new do |s|
  s.name = 'mail-ses'
  s.version = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip

  s.authors = ['Johnny Shields']
  s.date = '2018-08-17'
  s.description = 'Ruby Mail delivery method handler for Amazon SES'
  s.summary = 'Ruby Mail delivery method handler for Amazon SES'
  s.email = 'info@tablecheck.com'
  s.homepage = 'http://github.com/tablecheck/mail-ses'
  s.licenses = ['MIT']
  s.files = Dir.glob('lib/**/*') + %w[VERSION CHANGELOG.md LICENSE README.md]
  s.test_files = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_dependency('aws-sdk-ses', '>= 1.8')
  s.add_dependency('mail', '>= 2.2.5')
  s.add_development_dependency('rake', '>= 1')
  s.add_development_dependency('rspec', '>= 3.8')
  s.add_development_dependency('rubocop', '~> 0.57.0')
end
