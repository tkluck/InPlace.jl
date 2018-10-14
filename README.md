# InPlace.jl - in-place operations where possible

## Synopsis

```julia
using InPlace
a = big"1"
b = a
@inplace b += 2
a   # is now also equal to 3
```

## Description

This package exposes a single macro, `@inplace`, which applies the operation
in its expression argument in-place on the left-hand side (if it is mutable).

Examples:

```julia
@inplace a = f(args...)
@inplace a += expr
```

In the case where `a` is mutable, it is an implementation detail whether its
value is actually modified. For this reason, one should use this operation
only on values for which the current stackframe holds the only reference; e.g.
by using `deepcopy`.

## References

This package was created for speeding up [`PolynomialRings.jl`][poly].

[poly]: https://github.com/tkluck/PolynomialRings.jl
