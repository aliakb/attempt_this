module AttemptThis
	# Type-based exception filter.
	class ExceptionTypeFilter
		# Initializer.
		def initialize(exception_classes)
			@exception_classes = Array.new(exception_classes)
		end

		# Tells whether the given exception satisfies the filter.
		def include?(exception)
			@exception_classes.any?{|klass| exception.is_a?(klass)}
		end
	end
end
