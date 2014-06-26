module AttemptThis
  extend self

  # Attempts code block until it doesn't throw an exception or the end of enumerator has been reached.
  def attempt(enumerator, &block)
    raise(ArgumentError, 'Nil enumerator!') if enumerator.nil?

    impl = AttemptObject::get_object(enumerator)
    impl.attempt(block)
  end

  def enabled?
    @enabled.nil? || @enabled
  end

  def enabled=(value)
    @enabled = value
  end

  # Resets all static data (scenarios). This is intended to use by tests only (to reset scenarios)
  def self.reset
    AttemptObject.reset
  end
end
