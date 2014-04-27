Gem::Specification.new do |s|
  s.name				= 'attempt_this'
  s.version			= '1.0.0'
  s.date				= '2014-04-27'
  s.summary			= 'Retry policy mix-in'
  s.description		= <<EOM
Retry policy mix-in with configurable number of attempts, delays, exception filters, and fall back strategies.

See project's home page for usage examples and more information.
EOM
  s.authors			= ['Aliaksei Baturytski']
  s.email				= 'abaturytski@gmail.com'
  s.files				= `git ls-files`.split($/)
  s.homepage		= 'https://github.com/aliakb/attempt_this'
  s.license     = 'MIT'

  s.add_development_dependency('bundler')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('uuid')
end
