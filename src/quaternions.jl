# https://danceswithcode.net/engineeringnotes/quaternions/quaternions.html

import Base: +, -, *, /

"""
Quaternion

``q = w + x⋅i + y⋅j + z⋅k``
"""
@export struct Qt <: Number
   w::Cfloat
   x::Cfloat
   y::Cfloat
   z::Cfloat
   Qt(w::Real = 0, x::Real = 0, y::Real = 0, z::Real = 0) = new(w, x, y, z)
end

Qt(u::Vec{3}, θ::Real) = Qt(cos(θ/2), (u * sin(θ/2))...)
Qt(v::Vec{3}) = Qt(0, v...)
Qt(v::Vec{4}) = Qt(v...)
Qt(v::Vector{<:Real}) = Qt(Vec(v...))

const i = Qt(0, 1)
const j = Qt(0, 0, 1)
const k = Qt(0, 0, 0, 1)

Base.getindex(q::Qt, i::Integer) = getfield(q, i)
Base.iterate(q::Qt, i = 1) = i > 4 ? nothing : (q[i], i + 1)

Vec{3}(q::Qt) = Vec(q.x, q.y, q.z)
Vec(q::Qt) = Vec(q...)

Base.promote_rule(::Type{Qt}, ::Type{<:Real}) = Qt
Base.convert(::Type{Qt}, n::Real) = Qt(n)

-(q::Qt) = Qt(-1 * Vec(q))
-(q::Qt, p::Qt) = Qt(Vec(q) - Vec(p))
+(q::Qt, p::Qt) = Qt(Vec(q) + Vec(p))

*(q::Qt, n::Real) = Qt(n * Vec(q))
*(n::Real, q::Qt) = Qt(n * Vec(q))

/(q::Qt, n::Real) = Qt(Vec(q) / n)
/(::Real, ::Qt)   = error("Cannot divide real numbers by Quaternions")
/(q::Qt, p::Qt) = q * inv(p)

LinearAlgebra.norm(q::Qt) = norm(Vec(q))

Base.conj(q::Qt) = Qt(q.w) - Qt(Vec{3}(q))
Base.adjoint(q::Qt) = conj(q)
Base.inv(q::Qt) = q' / norm(q)

Mat{4}((a, b, c, d)::Qt) = Mat4([
   a  -b  -c  -d
   b   a  -d   c
   c   d   a  -b
   d  -c   b   a
])

*((w₁, x₁, y₁, z₁)::Qt, (w₂, x₂, y₂, z₂)::Qt) = Qt(
   (w₁ * w₂ - x₁ * x₂ - y₁ * y₂ - z₁ * z₂),
   (w₁ * x₂ + x₁ * w₂ + y₁ * z₂ - z₁ * y₂),
   (w₁ * y₂ + y₁ * w₂ + z₁ * x₂ - x₁ * z₂),
   (w₁ * z₂ + z₁ * w₂ + x₁ * y₂ - y₁ * x₂),
)

@export begin
   const X = Vec(1, 0, 0)
   const Y = Vec(0, 1, 0)
   const Z = Vec(0, 0, 1)
end

"""
      rotation(q::Qt) -> Mat4

Creates a `4x4` rotation matrix from the quaternion `q`.
"""
@export rotation((w, x, y, z)::Qt) = Mat4([
   (1 - 2y^2 - 2z^2) (2x*y - 2w*z)     (2x*z + 2w*y)      0
   (2x*y + 2w*z)     (1 - 2x^2 - 2z^2) (2y*z - 2w*x)      0
   (2x*z - 2w*y)     (2y*z + 2w*x)     (1 - 2x^2 - 2y^2)  0
   0                 0                 0                  1
])

function *(q::Qt, v::Vec{N}) where {N}
   @assert 4 >= N >= 1 "
      Quaternions can only act as rotations on 1-4 dimensional vectors.
      Got vector with $N dimensions
   "
   return rotation(q)[1:N, 1:N] * v
end

function Base.show(io::IO, (w, x, y, z)::Qt)
   f(x) = abs(x) == 1 ? "- $(abs(x))" : "+ $(x)"
   write(io, "($w $(f(x))i $(f(y))j $(f(z))k)")
end