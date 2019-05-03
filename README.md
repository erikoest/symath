# Sy

Symbolic math library for Ruby. This gem is only intended as an excercise. You should most
probably not want to use it in your application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sy

## Usage

The method to_m can be used to transform integers and strings/symbols into symbolic math numbers and variables,
respectively. The names pi, e, i, sq2 and phi have special meanings and will create the corresponding math
constants rather than free variables. The method fn(name, *args) can be used to create a function object. Some
of the function names have special meanings, so e.g. creating functions named 'sin' or 'exp' will create the
sine and exponential functions. Other unrecognized names will just create an unknown function of that name.

Creating a number:
    ten = 10.to_m

Creating variable:
    x = :x.to_m
    x = 'x'.to_m

Creating math constants:
    pi = :pi.to_m
    e = 'e'.to_m

Creating a known function:
    s = fn(:sin, x)
    s = fn(:exp, :x)

Creating an unknown function:
    s = fn(:myfunc, x, ten)

The base value object overrides the standard math operations for ruby (+, -, *, /, **, etc.) so value objects
can be combined into more complex expressions using these. The right side argument is converted into a
math object if it is an integr, a string or a symbol.

Composing expressions:
    sum = 10.to_m + :x.to_m**3
    power = :x.to_m**:y

The value objects implement the to_s method for turning an expression into a string.
    (10.to_m + :x.to_m**3).to_s  # => '10 + x^3'

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sy/blob/master/CODE_OF_CONDUCT.md).
