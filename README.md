# Sy

Rudimentary symbolic math library for Ruby. Caveat: This gem is mainly
intended as a coding excercise. The current state of the project is
'under construction'. There are currently too many bugs to list, and
many of the operations behave strangely.

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

### Simple introduction

A convenient way to explore the Sy library is using the interactive
ruby interpreter, irb:

The Sy library is a framework for building and manipulating symbolic
mathematical expressions. A symbolic expression can be composed by
first converting numbers and symbols into math objects, using the
method '.to_m'. The math objects can then be combined using the
operators 'x', '-', '*', '/' and '**':

```
> # Load the sy library
> require 'sy'
=> false
> # Add the symbols module to your environment
> extend Sy::Definitions
=> main
```

You can now say, for example:

```
> # Simplify an expression
> sin(:x) + 2*sin(:x)
=> 3*sin(:x)
> # Derivative of tan(2*x + 3)
> (d(tan(2*:x + 3))/d(:x)).evaluate
=> 2*(tan(2*x + 3)**2 + 1)
```

Ruby symbols, :x in the above example, are converted to symbolic math
variables and ruby numbers to symbolic math numbers. Functions,
operators and constants (e, pi, i, etc.) are available as methods
through the Sy::Definitions module. In some cases it is necessary to
tell ruby that your number or symbol is to be treated as a symbolic
object, using the to_m method:

```
> # Ruby integer math
> 3**4
=> 81
> # Sy symbolic math
> 3.to_m**4
=> 3**4
> (3.to_m**4).normalize
=> 81
```

An complete expression can also be converted from a string, using the
same to_m method:

```
> 'ln(e) + sin(pi/2)'.to_m
=> ln(e) + sin(pi/2)
> 'ln(e) + sin(pi/2)'.to_m.normalize
=> 2
```

### String representaton of symbolic objects

Symbolic math objects, inheriting from Sy::Value, all have a to_s
method which returns a string representation of the object. The string
representation is compatible with the String.to_m method which
converts a string representation into a symbolic object:

```
> (ln(e) + sin(pi/2)).to_s
=> "ln(e) + sin(pi/2)"
> 'ln(e) + sin(pi/2)'.to_m
=> ln(e) + sin(pi/2)
```

Sy::Value overrides the Object.inspect method, returning the to_s
representation rather than the more verbose and less readable
Object.inspect output. This behaviour can be disabled with the setting
'inspect_to_s':

```
> Sy.setting(:inspect_to_s, false)
=> false
> ln(e) + sin(pi/2)
=> "#<Sy::Sum:0x000055e8a1d93b38 @definition=\"\\\"#<Sy::Definition......"
```

### Simplification and normalizing

Simple reduction rules are automatically applied when composing an
expression. These can be disabled with the setting
'compose_with_simplify'. More thorough reductions are done by the use
of the normalize method.

```
> e*e*e*e
=> e**4
> Sy.setting(:compose_with_simplify, false)
=> false
> e*e*e*e
=> e*e*e*e
> sin(pi/2).normalize
=> 1
```

### Functions

The library comes with a number of built-in function, which the system
knows how to derivate and integrate over. The built-in functions also
have a number of reduction rules which are applied by the reduce
method and also as part of the 'normalize' method. A list of the
defined functions is returned by the functions method. The description
method gives a small description of the function:

```
> Sy::Definition::Function.functions
=> [sqrt, sin, cos, tan, sec, csc, cot, arcsin, arccos, arctan, arcsec, arccsc, arccot, ln, exp, abs, fact, sinh, cosh, tanh, coth, sech, csch, arsinh, arcosh, artanh, arcoth, arsech, arcsch]
> sin.description
```

### Defining functions

User-defined functions can be added by the method define_fn:

```
> define_fn('poly', [:x, :y], :x**3 + :y**2 + 1)
=> poly
```

The user-defined function will afterwards get a method in the
Sy::Definitions module so it can be used in expressions like the
built-in functions. Functions defined by an expression can be
evaluated by the evaluate method, which returns the expression with
each free variable replaced with the input arguments to the function:

```
> poly(2, 3).evaluate
=> 2**3 + 3**2 + 1
poly(3).evaluate.normalize
=> 18
```

### Lambda functions

A nameless user-defined function can be created using the lmd
method. The method returns a function object which does not have a
name, but otherwise works as a function. This is often useful when
defining operators (see 'defining operators' section below). The
lambda function can be called using the call method or the ruby 'call'
operator '()':

```
> l = lmd(:x**3 + :y**2 + 1, [:x, :y])
> l.(2, 3)
=> (x**3 + y**2 + 1).(2,3)
```

### Operators

The library also has some built-in operators. A list of the defined
operators is returned by the operators method. The description method
gives a small description of the operator:

```
> Sy::Definition::Operator.operators
=> [+, -, *, /, **, ^, =, d, xd, int, bounds, sharp, flat, hodge, grad, curl, div, laplacian, codiff, laplace, fourier, invfourier]
> codiff.description
=> "codiff(f) - codifferential of function f"
```

### Defining operators

...

### Evaluating functions and operators

Evaluating a functions or operators which is defined by an expression
returns the expression with each free variable replaced with input
arguments. Functions which do not have an expression will typically
evaluate to itself (no reduction). Most operators which do not have an
expression has a built in evaluation, and returns a function or
expression according to the operator.

### Derivation
Derivative of a function:

```
> (d(sin(:x))/d(:x)).evaluate
=> cos(:x)
```

Differential:

```
> d(sin(:x)).evaluate
=> cos*dx
```

Exterior derivative [f : f(x1, x2, x3)]:

```
xd(:f) --> f1'*dx1 + f2'*dx2 + f3'*dx3
```

Integration is available as an operator.

Indefinite integral (antiderivative):

int(:f, :dx)

Definite integral:

defint(:f, :dx, :a, :b)

### Complex numbers and quaternions

...

### Exterior algebra

...

### Vectors and matrices

...

### Methods for manipulating expressions

#### Normalization

#### Variable replacement

#### Matching and pattern replacement

#### Factorization

#### Expand product

### Settings

...

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake spec` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/sy. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sy project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/[USERNAME]/sy/blob/master/CODE_OF_CONDUCT.md).
