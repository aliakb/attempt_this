attempt_this
============

Exception-based retry policy mix-in for Ruby project. Its purpose it to retry a code block given number of times if it throws an exception.
```ruby

attempt(3.times) do
	# Do something
end
```
This will retry the code block up to three times. If the last attempt will result in an exception, that exception will be thrown outside of the attempt block.
If you don't like that behavior, you can specify a function to be called after all attempts have failed.
```ruby
is_failed = false
attempt(3.times)
.and_default_to(->{is_failed = true}) do
	# Do something
end
```

You may want to retry on specific exception types:
```ruby
attempt(3.times)
.with_filter(RecoverableError1, RecoverableError2) do
	# Do something
end
```

You may chose how to reset the environment between failed attempts. This is useful for transactions:
```ruby
attempt(3.times)
.with_reset(->{rollback}) do
	start_transaction
	# Do something
	commit_transaction
end
```
You can specify delay between failed attempts:

```ruby

# Wait for 5 seconds between failures.
attempt(3.times)
.with_delay(5) do
	# Do something
end

# Random delay between 30 and 60 seconds.
attempt(3.times)
.with_delay([30..60]) do
	# Do something
end

# Start with 10 seconds delay and double it after each failed attempt.
attempt(5.times)
.with_binary_backoff(10) do
	# Do something
end
```

Of course, you can combine multiple options together:
```ruby
attempt(3.times)
.with_delay(30)
.with_reset(->{rollback})
.and_default_to(->{is_failed = true}) do
    # Do something
end
```

Finally, you can store various configurations as scenarios and use them by name. This is useful when you need different approaches for specific cases (handling HTTP failures, for example). But remember that you should register your scenarios before using them:

```ruby
# Run this code when the application starts
AttemptThis.attempt(5.times).with_filter(*RECOVERABLE_HTTP_ERRORS).scenario(:http)


# And run this from your method:
attempt(:http) do
	# Make an HTTP call
end
```

Enjoy! And feel free to contribute; just make sure you haven't broken any tests by running 'rake' from project's root.
