Gem::Specification.new do |s|
	s.name				= 'attempt_this'
	s.version			= '0.8.0'
	s.date				= '2013-05-05'
	s.summary			= 'Retry policy mix-in'
	s.description	= 'Retry on exception with configurable number of times, delays, exception filters, and fall back strategies' 
	s.authors			= ['Aliaksei Baturytski']
	s.email				= 'abaturytski@gmail.com'
	s.files				= ['lib/attempt_this.rb', 'lib/attempt_this/attempt_object.rb', 'lib/attempt_this/binary_backoff_policy.rb', 'lib/attempt_this/exception_type_filter.rb']
	s.homepage		= 'https://github.com/aliakb/attempt_this'
end
