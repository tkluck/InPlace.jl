using Test
using InPlace

@testset "in-place operations" begin
    a = big"1"
    b = a
    c = deepcopy(a)

    @inplace a += 1
    @test a == b == 2
    @test c == 1

    @inplace a = -a
    @test a == b == -2
    @test c == 1

    @inplace a = a * -1
    @test a == b == 2
    @test c == 1

    @inplace a -= 1
    @test a == b == 1
    @test c == 1


    d = big"3"
    @inplace a = d
    @test a == b == d
    @test c == 1

    @inplace a *= d
    @test a == b == d^2

    @inplace a = 1 + a
    @test a == b == d^2 + 1

    @inplace a = 1 - a
    @test a == b == -d^2

    @inplace a = 3a
    @test a == b == -3d^2

    @inplace a = +d
    @test a == b == d

    d = big"20"
    e = big"6"
    @inplace a = rem(d, e)
    @test a == b == 2

    @inplace a = div(d, e)
    @test a == b == 3

    @inplace a = gcd(d, e)
    @test a == b == 2

    @inplace a = lcm(d, e)
    @test a == b == 60

    @inplace a = abs(d)
    @test a == b == 20

    @inplace a = flipsign(d, -1)
    @test a == b == -20

    A = BigInt[1, 1, 1]
    b = A[1]
    c= deepcopy(A[1])

    @inplace A .+= 1
    @test A[1] == b == 2
    @test c == 1

    @inplace A .= 5
    @test A[1] == b == 5
    @test c == 1

end
