require 'spec_helper.rb'

describe AttemptThis do
  include AttemptThis

  context 'attempt' do
    it 'should reject nil enumerator' do
      lambda{attempt(nil)}.should raise_error(ArgumentError)
    end

    it 'should allow execution without a code block' do
      lambda{attempt(3.times)}.should_not raise_error
    end

    it 'should execute code block' do
      was_called = false
      attempt(1.times) {was_called = true}
      was_called.should be true
    end

    it 'should execute the code block only once' do
      call_count = 0
      attempt(3.times) { call_count += 1 }
      call_count.should eql(1)
    end

    it 'should not execute the code' do
      call_count = 0
      attempt(0.times) { call_count += 1 }

      call_count.should eql(0)
    end

    it 'should re-throw the original exception' do
      lambda{attempt(2.times){raise 'Test'}}.should raise_error('Test')
    end

    it 'should attempt 3 times' do
      call_count = 0
      lambda{attempt(3.times) { call_count += 1; raise 'Test'}}.should raise_error('Test')
      call_count.should eql(3)
    end

    it 'should stop trying after a successful attempt' do
      attempt_count = 0
      attempt(3.times) do
        attempt_count += 1
        raise 'Test' if attempt_count < 2
      end

      attempt_count.should eql(2)
    end

    it 'should return block\'s value' do
      expected = "some string"
      attempt(3.times) { expected }.should eql(expected)
    end
  end

  context 'with_delay' do
    it 'should reject nil delay' do
      lambda{attempt(3.times).with_delay(nil)}.should raise_error(ArgumentError)
    end

    it 'should reject negative delay' do
      lambda{attempt(3.times).with_delay(-1)}.should raise_error(ArgumentError)
    end

    it 'should reject non-number delay' do
      lambda{attempt(3.times).with_delay('foo')}.should raise_error(ArgumentError)
    end

    it 'should accept floating point delay' do
      lambda{attempt(3.times).with_delay(1.5)}.should_not raise_error
    end

    it 'should accept zero delay' do
      lambda{attempt(3.times).with_delay(0)}.should_not raise_error
    end

    it 'should accept calls without a code block' do
      lambda{attempt(3.times).with_delay(3)}.should_not raise_error
    end

    it 'should call the code block' do
      was_called = false
      attempt(3.times).with_delay(1) do
        was_called = true
      end
      was_called.should be true
    end

    it 'should not sleep on success' do
      Kernel.should_not_receive(:sleep)
      attempt(3.times).with_delay(3) {}
    end

    it 'should sleep for given number of seconds between failed attempts' do
      Kernel.should_receive(:sleep).with(5).exactly(2).times
      lambda{attempt(3.times).with_delay(5) {raise 'Test'}}.should raise_error('Test')
    end

    it 'should not fail on zero delay' do
      lambda{attempt(3.times).with_delay(0) { raise 'Test' }}.should raise_error('Test')
    end

    it 'should reject negative start' do
      lambda{attempt(3.times).with_delay(-1..1)}.should raise_error(ArgumentError)
    end

    it 'should reject negative end' do
      lambda{attempt(3.times).with_delay(1..-1)}.should raise_error(ArgumentError)
    end

    it 'should reject non-number range' do
      lambda{attempt(3.times).with_delay('x'..'y')}.should raise_error(ArgumentError)
    end

    it 'should accept floating point range' do
      lambda{attempt(3.times).with_delay(1.5..3)}.should_not raise_error
    end

    it 'should reject inverse range' do
      lambda{attempt(2.times).with_delay(3..1)}.should raise_error(ArgumentError)
    end

    it 'should accept zero seconds interval' do
      lambda{attempt(3.times).with_delay(0..0)}.should_not raise_error
    end

    it 'should wait for specified number of seconds' do
      Kernel.should_receive(:sleep).with(5).exactly(2).times
      lambda{attempt(3.times).with_delay(5..5){raise 'Test'}}.should raise_error('Test')
    end

    it 'should reject multiple delay policies' do
      lambda{attempt(3.times).with_delay(1).with_delay(1)}.should raise_error(ArgumentError)
    end
  end

  context 'with_reset' do
    it 'should reject nil reset proc' do
      lambda{attempt(3.times).with_reset(nil)}.should raise_error(ArgumentError)
    end

    it 'should accept calls without a code block' do
      lambda{attempt(3.times).with_reset(lambda{})}.should_not raise_error
    end

    it 'should call the code block' do
      was_called = false
      attempt(1.times).with_reset(lambda{}) { was_called = true }

      was_called.should be true
    end

    it 'should reject multiple reset procs' do
      lambda{attempt(3.times).with_reset(lambda{}).with_reset(lambda{})}.should raise_error(ArgumentError)
    end

    it 'should not be called on successful calls' do
      was_called = false

      attempt(1.times).with_reset(lambda{ was_called = true }) {}
      was_called.should be false
    end

    it 'should be called on each failure' do
      reset_count = 0

      lambda{attempt(3.times).with_reset(lambda{ reset_count += 1 }) { raise 'Test' }}.should raise_error('Test')
      reset_count.should eql(3)
    end
  end

  context 'and_default_to' do
    it 'should reject nil default method' do
      lambda{attempt(3.times).and_default_to(nil)}.should raise_error(ArgumentError)
    end

    it 'should reject duplicate default methods' do
      lambda{attempt(3.times).and_default_to(lambda{}).and_default_to(lambda{})}.should raise_error(ArgumentError)
    end

    it 'should allow calls without a code block' do
      lambda{attempt(3.times).and_default_to(lambda{})}.should_not raise_error
    end

    it 'should call the code block' do
      was_called = false
      attempt(3.times).and_default_to(lambda{}){ was_called = true }

      was_called.should be true
    end

    it 'should not be called on success' do
      was_called = false
      attempt(3.times).and_default_to(lambda{ was_called = true }) {}
      was_called.should be false
    end

    it 'should be called once on the failure' do
      call_count = 0
      attempt(3.times).and_default_to(lambda{ call_count += 1 }){ raise 'Test'}

      call_count.should eql(1)
    end

    it 'should not be called if code block stopped failing' do
      call_count = 0
      was_called = false

      attempt(3.times).and_default_to(lambda{ was_called = true }) { call_count += 1; raise 'Test' if call_count < 2 }
      was_called.should be false
    end
  end

  context 'with_binary_backoff' do
    it 'should reject nil initial delay' do
      lambda{attempt(3.times).with_binary_backoff(nil)}.should raise_error(ArgumentError)
    end

    it 'should reject non-integer initial delay' do
      lambda{attempt(3.times).with_binary_backoff('foo')}.should raise_error(ArgumentError)
    end

    it 'should reject zero initial delay' do
      lambda{attempt(3.times).with_binary_backoff(0)}.should raise_error(ArgumentError)
    end

    it 'should reject negative initial delay' do
      lambda{attempt(3.times).with_binary_backoff(-1)}.should raise_error(ArgumentError)
    end

    it 'should reject multiple policies' do
      lambda{attempt(3.times).with_binary_backoff(1).with_binary_backoff(2)}.should raise_error(ArgumentError)
    end

    it 'should accept calls without a code block' do
      lambda{attempt(3.times).with_binary_backoff(1)}.should_not raise_error
    end

    it 'should call the code block' do
      was_called = false

      attempt(3.times).with_binary_backoff(1) { was_called = true }
      was_called.should be true
    end

    it 'should double delay on each failure' do
      Kernel.should_receive(:sleep).ordered.with(1)
      Kernel.should_receive(:sleep).ordered.with(2)
      Kernel.should_receive(:sleep).ordered.with(4)

      attempt(4.times).with_binary_backoff(1).and_default_to(lambda{}) { raise 'Test' }
    end
  end

  context 'with_filter' do
    it 'should reject empty exceptions list' do
      lambda{attempt.with_filter}.should raise_error(ArgumentError)
    end

    it 'should reject non-exceptions' do
      lambda{attempt.with_filter(1)}.should raise_error(ArgumentError)
    end

    it 'should accept calls without a block' do
      lambda{attempt(2.times).with_filter(Exception)}.should_not raise_error
    end

    it 'should call code within the block' do
      was_called = false
      attempt(2.times).with_filter(Exception){ was_called = true }
      was_called.should be true
    end

    it 'should ignore other exceptions' do
      count = 0
      lambda{attempt(3.times).with_filter(StandardError){ count += 1; raise(Exception, 'Test')}}.should raise_error(Exception)
      count.should eql(1)
    end

    it 'should not ignore specified exceptions' do
      count = 0
      lambda{attempt(3.times).with_filter(RuntimeError){ count += 1; raise 'Test'}}.should raise_error(RuntimeError)
      count.should eql(3)
    end

    it 'should not ignore derived exceptions' do
      count = 0
      lambda{attempt(3.times).with_filter(Exception){ count += 1; raise(StandardError, 'Test')}}.should raise_error(StandardError)
      count.should eql(3)
    end
  end

  context 'enabled' do
    class TestAttempt
      include AttemptThis
    end

    subject{TestAttempt.new}

    it 'should be true initially' do
      subject.enabled?.should be true
    end

    it 'should accept true' do
      subject.enabled = true
      subject.enabled?.should be true
    end

    it 'should accept false' do
      subject.enabled = false
      subject.enabled?.should be false
    end

    it 'should change from true to false' do
      subject.enabled = true
      subject.enabled = false
      subject.enabled?.should be false
    end

    it 'should change from false to true' do
      subject.enabled = false
      subject.enabled = true
      subject.enabled?.should be true
    end

    context 'when disabled' do
      before(:each) do
        AttemptThis.stub(:enabled?).and_return(false)
      end

      it 'should yield in the simplest case' do
        expect{|b| attempt(3.times, &b)}.to yield_control
      end

      it 'should yield with chained calls' do
        expect{|b| attempt(3.times).with_delay(100, &b)}.to yield_control
      end

      it 'should not retry' do
        count = 0
        expect{attempt(3.times) {count += 1; raise 'Test'}}.to raise_error('Test')
        count.should eql(1)
      end
    end
  end
end
