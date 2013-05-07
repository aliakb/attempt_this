require 'attempt_this/attempt_object.rb'

module AttemptThis
	# Attempts code block until it doesn't throw an exception or the end of enumerator has been reached.
	def attempt(enumerator, &block)
		raise(ArgumentError, 'Nil enumerator!') if enumerator.nil?

		impl = AttemptObject.new(enumerator)
		impl.attempt(block)
	end
end
