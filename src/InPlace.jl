module InPlace

# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------
"""
    a = inplace!(op, a, b...)

Compute and return `op(b...)`. If `a` is mutable, possibly modify its value
in-place.

In the case where `a` is mutable, it is an implementation detail whether its
value is actually modified, and for this reason, one should always _also_
assign the result of this call to `a`. Moreover, one should use it only
on values for which the current stackframe holds the only reference; e.g.
by using `deepcopy`.
"""
inplace!(op, a, b...) = op(b...)

"""
    a = inclusiveinplace!(op, a, b...)

Compute and return `op(a, b...)`. If `a` is mutable, possibly modify its value
in-place.

In the case where `a` is mutable, it is an implementation detail whether its
value is actually modified, and for this reason, one should always _also_
assign the result of this call to `a`. Moreover, one should use it only
on values for which the current stackframe holds the only reference; e.g.
by using `deepcopy`.
"""
inclusiveinplace!(op, a, b...) = inplace!(op, a, a, b...)

"""
    @inplace a = f(args...)
    @inplace a += expr

Compute `f(args...)` resp. `+(a, expr)` and assign the result to `a`. If `a` is
mutable, possibly modify its value in-place.

In the case where `a` is mutable, it is an implementation detail whether its
value is actually modified. For this reason, one should use this operation
only on values for which the current stackframe holds the only reference; e.g.
by using `deepcopy`.
"""
macro inplace(assignment)
    operation = collect(string(assignment.head))
    (isassignment = last(operation) == '=') && pop!(operation)
    (isbroadcast = !isempty(operation) && first(operation) == '.') && popfirst!(operation)
    hasinclusiveop = !isempty(operation)

    isassignment || error("Cannot use in-place operation for $(assignment.head) expression")

    tgt  = esc(assignment.args[1])

    head = isbroadcast ? :(.=) : :(=)

    if hasinclusiveop
        op = esc(Symbol(join(operation)))
        srcs = [esc(assignment.args[2])]
    elseif assignment.args[2] isa Expr && assignment.args[2].head == :call
        op   = esc(assignment.args[2].args[1])
        srcs = map(esc, assignment.args[2].args[2:end])
    else
        op = identity
        srcs = [esc(assignment.args[2])]
    end

    if isbroadcast && hasinclusiveop
        call = :( inclusiveinplace!.($op, $tgt, $(srcs...)) )
    elseif isbroadcast && !hasinclusiveop
        call = :( inplace!.($op, $tgt, $(srcs...)) )
    elseif !isbroadcast && hasinclusiveop
        call = :( inclusiveinplace!($op, $tgt, $(srcs...)) )
    elseif !isbroadcast && !hasinclusiveop
        call = :( inplace!($op, $tgt, $(srcs...)) )
    else
        error("not reachable")
    end

    return Expr(head, tgt, call)
end

export @inplace

# -----------------------------------------------------------------------------
#
# Implementations for BigInt
#
# -----------------------------------------------------------------------------
inplace!(::typeof(+), a::BigInt, b::BigInt, c::BigInt) = (Base.GMP.MPZ.add!(a,b,c); a)
inplace!(::typeof(-), a::BigInt, b::BigInt, c::BigInt) = (Base.GMP.MPZ.sub!(a,b,c); a)
inplace!(::typeof(*), a::BigInt, b::BigInt, c::BigInt) = (Base.GMP.MPZ.mul!(a,b,c); a)
inplace!(::typeof(*), a::BigInt, b::BigInt, c::Int) = (Base.GMP.MPZ.mul_si!(a,b,c); a)

inplace!(op, a::BigInt, b::BigInt, c::Integer) = inplace!(op, a, b, convert(BigInt, c))

inplace!(::typeof(+), a::BigInt, b::BigInt) = (Base.GMP.MPZ.set!(a,b); a)
inplace!(::typeof(-), a::BigInt, b::BigInt) = (Base.GMP.MPZ.neg!(a,b); a)



end # module
