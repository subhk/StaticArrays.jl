# Generic Cholesky decomposition for fixed-size matrices, mostly unrolled
if isdefined(Compat.LinearAlgebra, :non_hermitian_error)
    non_hermitian_error() = Compat.LinearAlgebra.non_hermitian_error("chol")
else
    non_hermitian_error() = throw(Compat.LinearAlgebra.PosDefException(-1))
end
@inline function LinearAlgebra.chol(A::StaticMatrix)
    ishermitian(A) || non_hermitian_error()
    _chol(Size(A), A)
end

@inline function LinearAlgebra.chol(A::LinearAlgebra.RealHermSymComplexHerm{<:Real, <:StaticMatrix})
    _chol(Size(A), A.data)
end
if VERSION < v"0.7.0-DEV.393"
    @inline LinearAlgebra._chol!(A::StaticMatrix, ::Type{UpperTriangular}) = chol(A)
else
    # TODO should return non-zero info instead of throwing on errors
    @inline LinearAlgebra._chol!(A::StaticMatrix, ::Type{UpperTriangular}) = (chol(A), 0)
end


@generated function _chol(::Size{(1,1)}, A::StaticMatrix)
    @assert size(A) == (1,1)

    quote
        $(Expr(:meta, :inline))
        T = promote_type(typeof(sqrt(one(eltype(A)))), Float32)
        similar_type(A,T)((sqrt(A[1]), ))
    end
end

@generated function _chol(::Size{(2,2)}, A::StaticMatrix)
    @assert size(A) == (2,2)

    quote
        $(Expr(:meta, :inline))
        @inbounds a = sqrt(A[1])
        @inbounds b = A[3] / a
        @inbounds c = sqrt(A[4] - b'*b)
        T = promote_type(typeof(sqrt(one(eltype(A)))), Float32)
        similar_type(A,T)((a, zero(T), b, c))
    end
end

@generated function _chol(::Size{(3,3)}, A::StaticMatrix)
    @assert size(A) == (3,3)

    quote
        $(Expr(:meta, :inline))
        @inbounds a11 = sqrt(A[1])
        @inbounds a12 = A[4] / a11
        @inbounds a22 = sqrt(A[5] - a12'*a12)
        @inbounds a13 = A[7] / a11
        @inbounds a23 = (A[8] - a12'*a13) / a22
        @inbounds a33 = sqrt(A[9] - a13'*a13 - a23'*a23)
        T = promote_type(typeof(sqrt(one(eltype(A)))), Float32)
        similar_type(A,T)((a11, zero(T), zero(T), a12, a22, zero(T), a13, a23, a33))
    end
end

# Otherwise default algorithm returning wrapped SizedArray
@inline _chol(s::Size, A::StaticArray) = s(Matrix(chol(Hermitian(Array(A)))))
