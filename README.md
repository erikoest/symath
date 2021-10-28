# Sy

Symbolic math library for Ruby. This gem is only intended as a coding excercise.

# Installation

Add this line to your application's Gemfile:

```
gem 'sy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sy

## Usage

Using the library:
```
require 'Sy'
```

### Simple example

The Sy library is a framework for building and manipulating symbolic mathematical expressions. A symbolic expression can be composed by first converting numbers and symbols into math objects, using the method '.to_m'. The math objects can then be combined using the operators 'x', '-', '*', '/' and '**':

```
require 'Sy'

a = 1.to_m
b = 3.to_m
x = :x.to_m

exp = x**b + a/b
```

A variable can be made either from a symbol or from a string. The two are equivalent:

```
a_from_str = 'a'.to_m
a_from_sym = :a.to_m
```

Once you have a math object, you can combine it with numbers, symbols and strings. They will then implicitly be converted by the '.to_m' method during the composition. In the following example, it is necessary to convert the 1.to_m since the fraction has preceedence over the sum, so 1/3 is evaluated before the sum x**3 + 1/3:

```
x = :x.to_m
exp = x**3 + 1.to_m/3
```

A complete symbolic expression can also be created from a string using the '.to_math' method. The expression can be converted back to a string by the '.to_s' method.

```
exp = 'x**3 + 1/3'.to_mexp
puts exp.to_s  -->  'x*'3 + 1/3'
```

Use a function in an expression by first creating the function object by the 'fn' method, then applying it to one or more arguments. In a string expression, a function can be used directly. In both cases, the function must already be known to the system.

```
fn(:sin).(:pi)
'sin(pi)'.to_mexp
```

An operator can be used in the same way.

```
op(:d).(:sin)
'd(sin)'.to_mexp
```

All functions, operators and constants are available as ruby methods in the module
Sy::Symbols which can be extended or included in your code:

```
extend Sy::Symbols

sin(pi) --> 0
d(sin) --> cos*dx
```

Various forms of derivation are available as an operators.

Derivative of a function:

```
d = op(:d)
d(sin)/d(:x)  --> cos
```

Differential:

```
d(:sin)  --> cos*dx
```

Partial derivative [f: f(x, y)]:

```
dpart(:f, :x) ---> df/dx
```

Total derivative [f : f(x, y)]:

```
dtot(:f)  --> [dpart(:f, :x), dpart(:f, :y)]
```

Exterior derivative [f : f(x1, x2, x3)]:

```
dext(:f) --> f1'*dx1 + f2'*dx2 + f3'*dx3
```

Integration is available as an operator.

Indefinite integral (antiderivative):

int(:f, :dx)

Definite integral:

defint(:f, :dx, :a, :b)

A function can be defined using the def method:

```
def(:f, args: [:x, :y, :z], exp: [:x**3 + :y**2 + :z + 1])
```

An operator can be defined in the same way:

```
def(:o, args: [:f, :g], exp: [op(:d).(:f)])
```

### Math objects

A symbolic mathematical expression is represented as an object which can be assigned to a variable. Primitive entities are instansiated 

### Primitive entities

#### Number

Instansiating a number:

#### Constant

Instansiating a constant:

  - Built in constants

#### Variable

Instansiating a variable:

#### Operator

Instansiating an operator:

  - Operator definition
  - Operator call
  - Built in operators

##### Operator call

#### Function

Instansiating vectors and matrices:

### Expression composition

a + b (addition)
a - b (subtraction)
- a   (negation
a * b (multiplication)
  - operator algebra
a / b (division)
a**b  (power)
a^b   (wedge product)

### Stringify

### Compose from string

### Methods to manipulate expressions

  - Normalization
  - Derivation
  - Integration
  - Variable replacement
  - Pattern replacement
  - Factorization
  - Expand product


The method to_m can be used to transform integers and strings/symbols
into symbolic math numbers and variables, respectively. The names pi,
e, i, sq2 and phi have special meanings and will create the
corresponding math constants rather than free variables. The method
fn(name, *args) can be used to create a function object. Some of the
function names have special meanings, so e.g. creating functions named
'sin' or 'exp' will create the sine and exponential functions. Other
unrecognized names will just create an unknown function of that name.

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
