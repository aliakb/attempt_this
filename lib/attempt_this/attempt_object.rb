require_relative 'binary_backoff_policy.rb'
require_relative 'exception_type_filter.rb'

module AttemptThis
	# Retry policy implementation.
	# This class is internal and is not supposed to be used outside of the module.
	class AttemptObject
		# Initializes object with enumerator.
		def initialize(enumerator)
			@enumerator = enumerator
		end

		# Executes the code block.
		def attempt(block)
			if (block)
				last_exception = nil
				first_time = true

				@delay_policy = ->{} unless @delay_policy
				@reset_method = ->{} unless @reset_method
				@exception_filter = ExceptionTypeFilter.new([StandardError]) unless @exception_filter 

				@enumerator.each do
					@delay_policy.call unless first_time
					last_exception = nil
					begin
						block.call
						break
					rescue => ex
						raise unless @exception_filter.include?(ex)
						last_exception = ex
						@reset_method.call
					end
					first_time = false
				end

				# Re-raise the last exception
				if (last_exception)
					if (@default_method)
						@default_method.call
					else
						raise last_exception
					end
				end
			end

			# Return self to allow chaining calls.
			self
		end

		# Specifies delay in seconds between failed attempts. 
		def with_delay(delay, &block)
			# Delay should be either an integer or a range of integers.
			if (delay.is_a?(Numeric))
				raise(ArgumentError, "Delay should be a non-negative number; got #{delay}!") unless delay >= 0
				delay = delay..delay
			elsif delay.is_a?(Range)
				raise(ArgumentError, "Range members should be numbers; got #{delay}!") unless delay.first.is_a?(Numeric) && delay.last.is_a?(Numeric)
				raise(ArgumentError, "Range members should be non-negative; got #{delay}!") unless delay.first >= 0 && delay.last >= 0
				raise(ArgumentError, "Range's end should be greater than or equal to range's start; got #{delay}!") unless delay.first <= delay.last
			else
				raise(ArgumentError, "Delay should be either an number or a range of numbers; got #{delay}!")
			end
			raise(ArgumentError, 'Delay policy has already been specified!') if @delay_policy
			@delay_policy = ->{Kernel.sleep(rand(delay))}

			attempt(block)
		end

		# Specifies reset method that will be called after each failed attempt.
		def with_reset(reset_method, &block)
			raise(ArgumentError, 'Reset method is nil!') unless reset_method
			raise(ArgumentError, 'Reset method has already been speicifed!') if @reset_method

			@reset_method = reset_method
			attempt(block)
		end

		# Specifies default method that should be called after all attempts have failed.
		def and_default_to(default_method, &block)
			raise(ArgumentError, 'Default method is nil!') unless default_method
			raise(ArgumentError, 'Default method has already been specified!') if @default_method

			@default_method = default_method
			attempt(block)
		end

		# Specifies delay which doubles between failed attempts.
		def with_binary_backoff(initial_delay, &block)
			raise(ArgumentError, "Delay should be a number; got ${initial_delay}!") unless initial_delay.is_a?(Numeric)
			raise(ArgumentError, "Delay should be a positive number; got #{initial_delay}!") unless initial_delay > 0
			raise(ArgumentError, "Delay policy has already been specified!") if @delay_policy

			@delay_policy = BinaryBackoffPolicy.new(initial_delay)
			attempt(block)
		end

		# Specifies exceptions 
		def with_filter(*exceptions, &block)
			raise(ArgumentError, "Empty exceptions list!") unless exceptions.size > 0
			# Everything must be an exception.
			exceptions.each do |e|
				raise(ArgumentError, "Not an exception: #{e}!") unless e <= Exception
			end

			raise(ArgumentError, "Exception filter has already been specified!") if @exception_filter

			@exception_filter = ExceptionTypeFilter.new(exceptions)
			attempt(block)
		end
	end
end
