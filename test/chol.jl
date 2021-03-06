using StaticArrays, Compat, Compat.Test, Compat.LinearAlgebra

@testset "Cholesky decomposition" begin
    if !isdefined(Compat.LinearAlgebra, :non_hermitian_error)
        PosDefException = Compat.LinearAlgebra.PosDefException
    else
        PosDefException = ArgumentError
    end
    @testset "1×1" begin
        m = @SMatrix [4.0]
        (c,) = chol(m)
        @test c === 2.0
    end

    @testset "2×2" for i = 1:100
        m_a = randn(2,2)
        #non hermitian
        @test_throws PosDefException chol(SMatrix{2,2}(m_a))
        m_a = m_a*m_a'
        m = SMatrix{2,2}(m_a)
        @test chol(Hermitian(m)) ≈ chol(m_a)
    end

    @testset "3×3" for i = 1:100
        m_a = randn(3,3)
        #non hermitian
        @test_throws PosDefException chol(SMatrix{3,3}(m_a))
        m_a = m_a*m_a'
        m = SMatrix{3,3}(m_a)
        @test chol(m) ≈ chol(m_a)
        @test chol(Hermitian(m)) ≈ chol(m_a)
    end
    @testset "4×4" for i = 1:100
        m_a = randn(4,4)
        #non hermitian
        @test_throws PosDefException chol(SMatrix{4,4}(m_a))
        m_a = m_a*m_a'
        m = SMatrix{4,4}(m_a)
        @test chol(m) ≈ chol(m_a)
        @test chol(Hermitian(m)) ≈ chol(m_a)
    end
    @testset "static blockmatrix" for i = 1:10
        m_a = randn(3,3)
        m_a = m_a*m_a'
        m = SMatrix{3,3}(m_a)
        @test chol(reshape([m, 0m, 0m, m], 2, 2)) ==
            reshape([chol(m), 0m, 0m, chol(m)], 2, 2)
    end
end
