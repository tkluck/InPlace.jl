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
