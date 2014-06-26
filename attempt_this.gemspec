Gem::Specification.new do |s|
  s.name        = 'attempt_this'
  s.version     = '1.0.2'
  s.date        = '2014-04-29'
  s.summary     = 'Retry policy mix-in'
  s.description = <<EOM
Retry policy mix-in with configurable number of attempts, delays, exception filters, and fall back strategies.

See project's home page for usage examples and more information.
EOM
  s.authors     = ['Aliaksei Baturytski']
  s.email       = 'abaturytski@gmail.com'
  s.files       = `git ls-files`.split($/)
  s.homepage    = 'https://github.com/aliakb/attempt_this'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency('bundler', '~> 1.6')
  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('rspec', '~> 2.13')
  s.add_development_dependency('simplecov', '~> 0.8')
end
