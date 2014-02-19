module AttemptThis
  # Implementation of binary backoff policy. Internal use only.
  class BinaryBackoffPolicy
    # Initializer.
    def initialize(initial_delay)
      @delay = initial_delay
    end

    # Calls the policy.
    def call
      Kernel.sleep(@delay)
      @delay *= 2
    end
  end
end
