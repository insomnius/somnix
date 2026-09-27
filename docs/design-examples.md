# Somnix design examples

These examples illustrate the agreed direction. No compiler exists yet; the snippets
are not executable or compiler-validated. Enum and pattern syntax remain provisional.

## Return and propagate errors

```ruby
enum DivideError
  ZeroDivisor
end

def divide(a: Float64, b: Float64) -> Result[Float64, DivideError]
  if b == 0.0
    return Err(DivideError.ZeroDivisor)
  end

  Ok(a / b)
end

def calculate() -> Result[Float64, DivideError]
  value = divide(10.0, 2.0)?
  Ok(value + 1.0)
end
```

`?` performs an early error return, not an exception throw. The value on the
successful path is unwrapped. Both functions use the same error type here.

## Handle an error locally

```ruby
match divide(10.0, 0.0)
when Ok(value)
  puts value
when Err(DivideError.ZeroDivisor)
  puts "Cannot divide by zero"
end
```

Error variants will also support structured context. The precise declaration and
construction syntax for payload-bearing variants is still to be specified.

## Wait for tasks; send values through a channel

```ruby
def square(value: Int64) -> Int64
  value * value
end

def main()
  wg = WaitGroup.new()
  results = Channel[Int64].new(capacity: 2)

  spawn(wg) do
    results.send(square(12))
  end

  spawn(wg) do
    results.send(square(20))
  end

  wg.wait()

  puts results.receive()
  puts results.receive()
end
```

The channel can hold both messages before the receiver runs. Output is 144 and 400,
in an unspecified order. With insufficient channel capacity, this ordering of wait
and receive can deadlock. The wait group reports completion, not task errors.

This simplified example does not specify channel closure or allocation/start failures;
their APIs must be resolved before these snippets become executable examples.
