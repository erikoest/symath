# SyMath

Rudimentary symbolic math library for Ruby. This gem is mainly intended
as a coding exercise. The operations have not been optimized for speed.
The current state of the project is 'under construction'.

Supported features:
  * Composing formulas from +, -, *, / and other standard algebraic operations
  * Reduction rules
  * Derivation
  * Simple heuristic integration (not cad-level)
  * Simple polynomial factorization with one variable
  * Complex numbers and quaternions
  * Exterior algebra and exterior derivative (limited and possibly faulty)
  * Operator composition algebra (limited)
  * Vectors and linear forms
  * Braket notation for vectors, forms and linear operators
  * Matrices

# Installation

Add this line to your application's Gemfile:

```
gem 'symath'
```

Then execute:

    $ bundle

Or install it yourself as:

    $ gem install symath

## Usage

Using the library:

<pre>
  > require 'SyMath'
</pre>

### Simple introduction

A convenient way to explore the SyMath library is using the interactive
Ruby interpreter, irb:

<pre>
  > # Load the symath library
  > require 'symath'
  => false
  > # Add the symbols module to your environment
  > extend SyMath::Definitions
  => main
</pre>

You can now say, for example:

<pre>
  > # Simplify an expression
  > sin(:x) + 2*sin(:x)
  => 3*sin(:x)
  > # Derivative of tan(2*y + 3)
  > (d(tan(2*:y + 3))/d(:y)).evaluate
  => 2*(tan(2*y + 3)**2 + 1)
</pre>

Ruby symbols, :x and :y in the above example, are converted into
symbolic math variables and Ruby numbers are converted into symbolic
math numbers. Functions, operators and constants (e, pi, i, etc.) are
available as methods through the SyMath::Definitions module. In some cases
it is necessary to tell Ruby that your number or symbol is to be
understood as a symbolic object, and not just a Ruby number or
symbol. Use the to_m method to explicitly convert them to symbolic
bjects:

<pre>
  > # Ruby integer math
  > 3**4
  => 81
  > # SyMath symbolic math
  > 3.to_m**4
  => 3**4
  > (3.to_m**4).normalize
  => 81
</pre>

An complete expression can also be converted from a string, using the
same to_m method:

<pre>
  > 'ln(e) + sin(pi/2)'.to_m
  => ln(e) + sin(pi/2)
  > 'ln(e) + sin(pi/2)'.to_m.normalize
  => 2
</pre>

### The SyMath::Definitions module

The module SyMath::Definitions is available to be included or extended
to your class or code block. It gives a Ruby method for each operator,
function and constant that exists, so they can be referred to by their
name, as in the code examples above. If you don't want to use the
module, functions, operators and constants must be referred to by the
fn, op and definition methods:

<pre>
  > # Using the SyMath::Definitions methods
  > sin(:x)
  => sin(x)
  > int(:x)
  => int(x)
  > e
  => e
  > sin
  => sin(...)
  > # Using the generic creator functions
  > fn(:sin, :x)
  => sin(x)
  > op(:int, :x)
  => int(x)
  > definition(:e)
  => e
  > definition(:sin)
  => sin(...)
</pre>

The SyMath::Definitions module is updated dynamically after the user has
defined new functions, operators and constants.

### String representaton of symbolic objects

Symbolic math objects, inheriting from SyMath::Value, all have a to_s
method which returns a string representation of the object. The string
representation is compatible with the String.to_m method which
converts a string representation into a symbolic object:

<pre>
  > (ln(e) + sin(pi/2)).to_s
  => "ln(e) + sin(pi/2)"
  > 'ln(e) + sin(pi/2)'.to_m
  => ln(e) + sin(pi/2)
</pre>

SyMath::Value overrides the Object.inspect method, returning the to_s
representation rather than the more verbose and less readable
Object.inspect output. This behaviour can be disabled with the setting
'inspect_to_s':

<pre>
  > SyMath.setting(:inspect_to_s, false)
  => false
  > ln(e) + sin(pi/2)
  => "#&lt;SyMath::Sum:0x000055e8a1d93b38 @definition=..."
</pre>

### Simplification and normalizing

Simple reduction rules are automatically applied when composing an
expression. These can be disabled with the setting
'compose_with_simplify'. More thorough reductions are done by the use
of the normalize method.

<pre>
  > e*e*e*e
  => e**4
  > SyMath.setting(:compose_with_simplify, false)
  => false
  > e*e*e*e
  => e*e*e*e
  > sin(pi/2).normalize
  => 1
</pre>

### Functions

The library comes with a number of built-in function, which the system
knows how to derivate and integrate over. The built-in functions also
have a number of reduction rules which are applied by the reduce
method and also as part of the 'normalize' method. A list of the
defined functions is returned by the functions method. The description
method gives a small description of the function:

<pre>
  > SyMath::Definition::Function.functions
  => [sqrt, sin, cos, tan, sec, csc, cot, arcsin, arccos, arctan,
      arcsec, arccsc, arccot, ln, exp, abs, fact, sinh, cosh, tanh,
      coth, sech, csch, arsinh, arcosh, artanh, arcoth, arsech,
      arcsch]
  > sin.description
  => "sin(x) - trigonometric sine"
</pre>

### Defining functions

User-defined functions can be added by the method define_fn:

<pre>
  > define_fn('poly', [:x, :y], :x**3 + :y**2 + 1)
  => poly
</pre>

The user-defined function will now be available as a method in the
SyMath::Definitions module and can be used in expressions, just as the
built in functions. Functions defined by an expression can be
evaluated by the evaluate method, which returns the expression with
each free variable replaced with the input arguments to the function:

<pre>
  > poly(2, 3).evaluate
  => 2**3 + 3**2 + 1
  > poly(3).evaluate.normalize
  => 18
</pre>

### Lambda functions

A nameless user-defined function can be created using the lmd
method. The method returns a function object which does not have a
name, but otherwise works as a function. The lambda function has
important usages in operators. Since they eturn a function as the
result, it will typically be a lambda function. Also, the lambda
function can be used for wrapping an expression into a function before
doing an integral or derivative, in this way telling which variables
the operator should work on. The lambda function can be called using
the call method or the Ruby 'call' operator '()':

<pre>
  > l = lmd(:x**3 + :y**2 + 1, :x, :y)
  > l.(2, 3)
  => (x**3 + y**2 + 1).(2,3)
  > l.(2, 3).evaluate
  => 2**3 + 3**2 + 1
  > l.(2, 3).evaluate.normalize
  => 18
</pre>

### Operators

The library has some built-in operators, i.e. functions which take
functions as arguments and return functions. A list of the defined
operators is returned by the operators method. The description method
gives a small description of the operator:

<pre>
  > SyMath::Definition::Operator.operators
=> [d(...), xd(...), int(...), [f](b,), #(), b(), hodge(...), grad(f),
    curl(f), div(f), laplacian(f), codiff(f), laplace(f), fourier(f),
    invfourier(f), dpart(f,t)]
  > codiff.description
  => "codiff(f) - codifferential of function f"
</pre>

### Defining operators

User-defined operators can be added by the method define_op:

<pre>
  > define_op('d2', [:f, :x], d(d(:f)/d(:x))/d(:x))
  => d2
  > d2(:x**3 + 2, :x).evaluate
  => 6*x
</pre>

The user-defined function will now be available as a method in the
SyMath::Definitions module and can be used in expressions.

### Evaluating functions and operators

Evaluating a functions or operators which is defined by an expression
returns the expression with each free variable replaced with input
arguments. Functions which do not have an expression will typically
evaluate to itself (no reduction). Most operators which do not have an
expression has a built in evaluation, and returns a function or
expression according to the operator.

### Derivative

The d-operator returns the differential of a function or expresson. If
a function is given, the differential is made over all the free
variables of the function. If an expression is given, the operator
differentiates over the first free variable found in the
expression. Wrapping the expression into a lambda function makes it
possible to say which variables to differentiate over. Note that the
differential is an operator, so it returns the result in a a lambda
function, and not just the expression.

<pre>
  > d(sin(:x)).evaluate
  => cos(x)*dx.(x)
  > d(:x**2 + :y**3 + 1).evaluate.normalize
  => (2*x*dx).(x)
  > d(lmd(:x**2 + :y**3 + 1, :y)).evaluate.normalize
  => (3*y**2*dy).(y)
  > d(lmd(:x**2 + :y**3 + 1, :x, :y)).evaluate.normalize
  => (3*y**2*dy + 2*x*dx).(x,y)
</pre>

As a special case, the notatonal form d(f)/d(x) is recognized as the
derivative of f with regards to x. This is calculated as d(lmd(f,
x))/d(x). This evaluates to the derivative expression:

<pre>
  > (d(:y**2 + :x**3 + 1)/d(:x)).evaluate
  => 3*x**2
</pre>

The partial derivative is available as well as 'syntactic sugar':

<pre>
  > dpart(:x**2 + :y**3 + 1, :x).evaluate.normalize
  => 2*x
  > dpart(:x**2 + :y**3 + 1, :y).evaluate.normalize
  => 3*y**2
</pre>

### Integration

Integration is available as the int-operator. The algorithm is only a
very simple one, imitating the most basic techniques of finding the
anti-derivative, combined with a few well known equation patterns. The
operation also has a limitation when it comes to non-commutable
terms (matrices, quaternions, etc.). In that case, the result is not
reliable.

With one argument, the operator evaluates to the antiderivative of the
expression:

<pre>
  > int(2**:x).evaluate
  => 2**x/ln(2) + C
</pre>

The variable C is used by convention to represent the free constant
factor of the antiderivative.

With three arguments, the int-operator evaluates to the definite
integral from a to b:

<pre>
  > int(2**:x, 3, 4).evaluate.normalize
  => 8/ln(2)
</pre>

### Complex numbers and quaternions

The imaginary unit, i, is available as a constant, and can be used for
composing expressions with complex numbers. Simple reduction rules are
built in which reduces i*i to -1, and so on.

The basic quaternions, i, j, k are also available as constants. The
quaternion i is identical to the complex imaginary unit. Some simple
reduction rules are available for the quaternions as well.

### Vectors, oneforms and linear operators

Variables can be defined as vectors, oneforms, multilinear forms and
other vector-like objects by specifying a type when created. Vector-like
objects are associated with a vector space. The 'vector space' is
matematically speaking an abuse of the term since vectors, n-forms
and other linear operators live in separate vector spaces (typically
denoted as V, V^V and VxVx...xV). They are, however, closely related,
and share many properties. So we let all these vector-like object
share their vector space. This may be changed in the future.

The vector space may be defined with a set of basis vectors and a
metric. This is optional, but a requirement if the vectors are to be
used with the exteriar algebra operations (see next section).

A set of built-in vector spaces are created at startup, and a default
space, the euclidean_3d, is chosen. Vector-like objects in an
expression can be put on matrix representation by the method to_matrix
(only objects which has an obvious representation, like basis vectors
and other known objects, are converted).

Vector-vector and oneform-oneform multiplications are automatically
composed into outer products. Oneform-vector products are, on the
other hand, composed into inner products. Vectors and oneforms
multiplied with a linear operator are composed into a normal product,
which is interpreted as an operator composition operation.

<pre>
  > # Create vector objects within the default vector space
  > a1 = :a1.to_m('vector')
  > a2 = :a2.to_m('form')
  > # Create objects within a given vector space
  > b = :b.to_m('vector', 'minkowski_4d')
  > c = :c.to_m('form', 'minkowski_4d')
  > m4 = SyMath.get_vector_space('minkowski_4d')
  > d = m4.vector(:d)
  > e = m4.oneform(:e)
  > # Set the default vector space
  > SyMath.list_vector_spaces
  => ["euclidean_3d", "minkowski_4d", "quantum_logic"]
  > SyMath.set_default_vector_space('minkowski_4d')
  => minkowski_4d ([x0, x1, x2, x3])
  > # Create a new vector space, and create a vector in it
  > myspace = SyMath::VectorSpace.new('myspace', dimension: 5,
        basis: [:v, :w, :x, :y, :z].to_m)
  > SyMath.list_vector_spaces
  => ["euclidean_3d", "minkowski_4d", "quantum_logic", "myspace"]
  > v1 = myspace.vector(:v1)
</pre>

### Normalized vector spaces, Bra-ket notation and the quantum logic space

A vector space can be defined as 'normalized'. In this case, all
vectors, co-vectors and linear operators are assumed to be
unitary. Vectors in normalized vector spaces are stringified in
bra-ket/dirac notation form since such vector spaces are often used in
quantum mechanical formula. The bra-ket notation is available for all
vectors in the String.to_m parser.

<pre>
  > norm = SyMath::VectorSpace.new('norm', dimension: 3,
        basis: [:a, :b, :c].to_m, normalized: true )
  > SyMath.set_default_vector_space('norm')
  => norm ([a, b, c])
  > 'A B|c>'.to_m
  => A B|c>
  > '<a|a>'.to_m.normalize
  => 1
  > '|a>|b>'.to_m
  => |a,b>
  </pre>

A built-in normalized vector space, 'quantum_logic', is available. It
has the basis vectors '|0>' and '|1>', and various linear operators
corresponding to quantum logical gates like, qX, qY, qZ, qH,
qS. Simple reduction rules exist between these objects. They can also
be converted to matrix form for further calculations.

<pre>
  > SyMath.set_default_vector_space('quantum_logic')
  => quantum_logic ([q0, q1])
  > 'qX|0>'.to_m
  => qX|0>
  > 'qX|0>'.to_m.normalize
  => |1>
  > '<1|qX|0>'.to_m.normalize
  => 1
  > 'qH|0>'.to_m.normalize
  => |+>
</pre>

### Exterior algebra

Caveat: Exterior algebra and differential forms are not well
understood by the author of this code. The following has not been
reviewed by any others who understand the subject better than me, and
it may very well contain a lot of errors and misunderstandings.

Forms can be defined in several ways. The following are equal. All
of them will create a oneform in the default vector space:

<pre>
  > # Using the to_d method on a scalar variable
  > :x.to_m.to_d
  => dx
  > # Differentiating a scalar variable
  > d(:x)
  => dx
  > # Creating a variable, and specifying the form type
  > :dx.to_m('form')
  => dx
</pre>

Forms can be wedged together, forming n-forms (note that the ^
operator has lower preceedence in Ruby than in math, so parantheses
must be used, e.g. when adding):

<pre>
  > d(:x)^d(:y)^d(:z)
  => dx^dy^dz
  > (d(:x)^d(:x)^d(:z)).normalize
  => 0
</pre>

The exterior derivative and related operators all work in a local
coordinate system defined by the basic vectors of the current
vector space.

The rest of this section assumes that the following scalars, vectors
and d-forms are defined:

<pre>
  > SyMath.assign_variable('basis', [:x1, :x2, :x3])
  => {dx1=>x1', dx2=>x2', dx3=>x3'}
  > x1  = :x1.to_m
  > x2  = :x2.to_m
  > x3  = :x3.to_m
  > x1v = :x1.to_m('vector')
  > x2v = :x2.to_m('vector')
  > x3v = :x3.to_m('vector')
  > dx1 = :dx1.to_m('form')
  > dx2 = :dx2.to_m('form')
  > dx3 = :dx3.to_m('form')
</pre>

The exterior derivative is available as the xd-operator:

<pre>
  > xd(:x1 - :x1*:x2 + :x3**2).evaluate
  => dx1 - (dx1*x2 + x1*dx2) + 2*x3*dx3
</pre>

The musical isomorphisms are available as the flat and sharp operators:

<pre>
  > flat(x1v^x2v).evaluate
  => dx1^dx2
  > sharp(dx1^dx2).evaluate
  => x1'^x2'
</pre>

The flat and sharp operators use the metric tensor in their
calculations and thus require that the current vector space
has a metric.

The hodge star operator is available as well:

<pre>
  > hodge(dx1^dx2).evaluate
  => dx3
  > hodge(3).evaluate
  => 3*dx1^dx2^dx3
</pre>

Gradient, curl, divergence, laplacian and co-differential are defined
from the above operators in the usual way:

<pre>
  > grad(x1 - x1*x2 + x3**2).evaluate
  => 2*x3*x3' - x2*x1' - x1*x2' + x1'
  > curl(-x2*x1v + x1*x2*x2v + x3*x3v).evaluate
  => x2*x3' + x3'
  > div(-x2*x1v + x1*x2*x2v + x3*x3v).evaluate
  => x1 + 1
  > laplacian(x1**2 + x2**2 + x3**2).evaluate
  => 6
  > codiff(x1**2*(dx1^dx3) + x2**2*(dx3^dx1) + x3**2*(dx1^dx2)).evaluate
  => 2*x1*dx3
</pre>

### Matrices

Row matrices can be defined in the coordinate array form by converting an
array to a math object, using the to_m method. Column matrices and two
dimensional matrices can be created the same way from two dimensional arrays:

<pre>
  > m = [[1, 2, 3], [4, 5, 6]].to_m
  > v = [-3, 4, 1].to_m
  > m*v.transpose
  => [1, 2, 3; 4, 5, 6]*[- 3; 4; 1]
  > (m*v.transpose).evaluate
  => [8; 14]
</pre>

The vector and matrix cells can of course contain symbolic expressions
instead of just numbers.

### Methods for manipulating expressions

The library contains a few more complex expression manipulation
methods which are available to all math expression objects inheriting
from the SyMath::Value class (the root class of the expression
components).

#### Normalization

The normalization method tries to put an expression on a normal form,
based on some heuristics. 

* Expressions formed by natural numbers are calculated.
* Fractions of natural numbers are simplified as far as possible.
* Products of equal factors are collapsed to power expressions.
* Products of powers with equal base are collapsed.
* Sums of equal terms are simplified to integer products.
* Product factors are ordered if permitted by commutativity.
* Sum terms are ordered.

<pre>
  > # FIXME: Find some better examples
  > (:x*4*:x*3*:y*:y**10).normalize
  => 12*x**2*y**11
</pre>

#### Variable replacement

The replace method replaces takes a map of 'variable => expression' as
argument. It looks up all instances of the variables in the original
expression, and replaces them with the expressions given by the map:

<pre>
  > (:x**:y).replace({:x.to_m => :a + 2, :y.to_m => :b + 3})
  => (a + 2)**(b + 3)
</pre>

#### Matching and pattern replacement

The match method can be seen as a 'reverse' operation to
replace-method covered in the last section. It compares an expression
to a template expression containing some free variables. It returns an
array of all possible maps for the free variables in the template so
that it matches the original expression:

<pre>
  > (:x**2 + :y**2 + 3).match(:a + :b, [:a.to_m, :b.to_m])
  => [{a=>x**2, b=>y**2 + 3},
      {a=>y**2, b=>x**2 + 3},
      {a=>3, b=>x**2 + y**2},
      {a=>x**2 + y**2, b=>3},
      {a=>x**2 + 3, b=>y**2},
      {a=>y**2 + 3, b=>x**2}]
</pre>

#### Match/replace operation

The match_replace method tries to find an occurence of a pattern in
the expression, and replaces it if it is found. The method can be used
together with the iterate method. The latter repeats a method until
there are no more changes:

<pre>
  > a = sin(sin(sin(:a + :b) - sin(:f)))
  > a.match_replace(sin(:x), :e*:x, [:x])
  => e*sin(sin(a + b) - sin(f))
  > a.iterate('match_replace', sin(:x), :e*:x, [:x])
  => e*e*(e*(a + b) - e*f)
</pre>

#### Factorization and product expansion

The factorization method has been ripped from the python
Py-library. It factorizes a polynomial of one variable:

<pre>
  > (6*:x**2 + 24*:x**3 - 27*:x**4 + 18*:x**5 + 72*:x**6 - 9*:x).factorize
  => 3*x*(2*x - 1)*(4*x + 3)*(3*x**3 + 1)
</pre>

The expand method expands the polynomial:

<pre>
  > (3*:x*(2*:x - 1)*(4*:x + 3)*(3*:x**3 + 1)).expand.normalize
  => 72*x**6 + 18*x**5 - 27*x**4 + 24*x**3 + 6*x**2 - 9*x
</pre>

### Settings

The library has some global settings which change the behaviour of the system:

<pre>
  > # List all settings
  > SyMath.settings
  => {
      # Symbol used when a vector is stringified
      :vector_symbol            => "'",
      # Show all parentheses when stringifying an expression
      :expl_parentheses         => false,
      # Put square roots on exponent form
      :sq_exponent_form         => false,
      # Put fractions on exponent form
      :fraction_exponent_form   => false,
      # In latex strings, insert a product sign between the factors
      :ltx_product_sign         => false,
      # Use simplification rules when expressions are composed
      :compose_with_simplify    => true,
      # Use oo as complex infinity
      :complex_arithmetic       => true,
      # Return to_s representation by the inspect method
      :inspect_to_s             => true,
      # Maximum value of factorial which is normalized to a number
      :max_calculated_factorial => 100
     }
  > # Show one setting
  > SyMath.setting(:vector_symbol)
  => "'"
  > # Change a setting
  > SyMath.setting(:vector_symbol, '¤')
  => "¤"
</pre>

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
https://github.com/erikoest/symath. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SyMath project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/erikoest/symath/blob/master/CODE_OF_CONDUCT.md).
