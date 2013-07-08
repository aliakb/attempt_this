require 'spec_helper'

describe AttemptThis do
	include AttemptThis

	before(:each) do
		AttemptThis.reset
	end

	context 'validation' do
		it 'should reject nil scenario id' do
			->{AttemptThis.attempt(3.times).scenario(nil)}.should raise_error(ArgumentError)
		end

		it 'should reject empty scenario id' do
			->{AttemptThis.attempt(3.times).scenario('')}.should raise_error(ArgumentError)
		end

		it 'should accept string ids' do
			->{AttemptThis.attempt(3.times).scenario('uploads')}.should_not raise_error
		end

		it 'should accept symbol ids' do
			->{AttemptThis.attempt(3.times).scenario(:uploads)}.should_not raise_error
		end

		it 'should reject duplicate names' do
			AttemptThis.attempt(3.times).scenario(:uploads)
			->{AttemptThis.attempt(3.times).scenario(:uploads)}.should raise_error(ArgumentError)
		end
	end

	context 'operation' do
		it 'should attempt given number of times' do
			AttemptThis.attempt(3.times).scenario(:test)
			count = 0

			->{attempt(:test) { count += 1; raise 'Test' }}.should raise_error('Test')
			count.should eql(3)
		end

		it 'should reuse scenario' do
			AttemptThis.attempt(3.times).scenario(:test)
			->{attempt(:test) { raise 'Test'}}.should raise_error('Test')

			count = 0
			->{attempt(:test) {count += 1; raise 'Test'}}.should raise_error('Test')
			count.should eql(3)
		end
	end
end
