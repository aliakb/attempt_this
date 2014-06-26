module AttemptThis
  # Retry policy implementation.
  # This class is internal and is not supposed to be used outside of the module.
  class AttemptObject
    @@scenarios = {}					# All registered scenarios

    # Resets all static data.
    def self.reset
      @@scenarios = {}
    end

    def self.get_object(id_or_enumerator)
      impl = @@scenarios[id_or_enumerator]
      impl ||= AttemptObject.new(id_or_enumerator)
      impl
    end

    # Initializes object with enumerator.
    def initialize(enumerator)
      @enumerator = enumerator
    end

    # Executes the code block.
    def attempt(block)
      # Returning self will allow chaining calls
      return self unless block
      return block.call unless AttemptThis.enabled?

      apply_defaults

      # Retriable attempts require special error handling
      result = each_retriable_attempt do
        return attempt_with_reset(&block)
      end

      # Final attempt
      if (result != :empty)
        @delay_policy.call unless result == :skipped
        final_attempt(&block)
      end
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
      @delay_policy = lambda{Kernel.sleep(delay.first + rand(delay.count))}

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

    # Creates a scenario with the given id.
    def scenario(id)
      raise(ArgumentError, 'Nil id!') if id.nil?
      raise(ArgumentError, "There is already a scenario with id #{id}") if @@scenarios.has_key?(id)

      @@scenarios[id] = self
    end

    private


    def final_attempt(&block)
      attempt_with_reset(&block)
    rescue Exception => ex
      raise unless @default_method
      raise unless @exception_filter.include?(ex)
      @default_method.call
    end

    def apply_defaults
      @delay_policy = lambda{} unless @delay_policy
      @reset_method = lambda{} unless @reset_method
      @exception_filter = ExceptionTypeFilter.new([StandardError]) unless @exception_filter
    end

    def each_retriable_attempt(&block)
      result = :empty
      @enumerator.each do
        if (result == :empty)
          result = :skipped
          next
        end
        @delay_policy.call unless result == :skipped
        result = :attempted
        begin
          block.call
        rescue Exception => ex
          raise unless @exception_filter.include?(ex)
        end
      end
      result
    end

    def attempt_with_reset(&block)
      block.call
    rescue Exception => ex
      @reset_method.call
      raise
    end
  end
end
