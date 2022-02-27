module Math

using LinearAlgebra
using InlineExports
using StaticArrays

@export begin
   const Vec{N} = SVector{N,  Cfloat}
   const Mat{N} = SMatrix{N, N, Cfloat}
   const Mat2   = Mat{2}
   const Mat3   = Mat{3}
   const Mat4   = Mat{4}
end

Vec(coords::Vararg{<:Real, N}) where {N} = Vec{N}(coords...)
Mat{N}() where {N} = Mat{N}(StaticArrays.I)

include("quaternions.jl")

@export translate(x::Real, y::Real, z::Real) = Mat4([
   1 0 0 x
   0 1 0 y
   0 0 1 z
   0 0 0 1
])

@export scale(x::Real, y::Real, z::Real) = Mat4([
   x 0 0 0
   0 y 0 0
   0 0 z 0
   0 0 0 1
])

scale(s::Real) = scale(s, s, s)

@export rotate(axis::Vec{3}, θ::Real) = rotation(Qt(axis, θ))
rotate(pairs::Pair{Vec{3}, <:Real}...) = prod(Qt(axis, θ) for (axis, θ) in pairs) |> rotation

@export rotateX(θ::Real) = rotate(X => θ)
@export rotateY(θ::Real) = rotate(Y => θ)
@export rotateZ(θ::Real) = rotate(Z => θ)

@export scaleX(x::Real) = scale(x, 1, 1)
@export scaleY(y::Real) = scale(1, y, 1)
@export scaleZ(z::Real) = scale(1, 1, z)

@export translateX(x::Real) = translate(x, 1, 1)
@export translateY(y::Real) = translate(1, y, 1)
@export translateZ(z::Real) = translate(1, 1, z)

@export function lookAt(eye::Vec{3}, center::Vec{3}, up::Vec{3})
   Z = normalize(center - eye)
   X = normalize(Z × up)
   Y = X × Z

   Mat4([
      X.x X.y X.z (-(X ⋅ eye))
      Y.x Y.y Y.z (-(Y ⋅ eye))
      Z.x Z.y Z.z (-(Z ⋅ eye))
      0   0   0   1
   ])
end

@export function ortho(left::Real, right::Real, bottom::Real, top::Real, near::Real, far::Real)
   Mat4([
      (2 / (right - left)) 0 0 (- ((right + left) / (right - left)))
      0 (2 / (top - bottom)) 0 (- ((top + bottom) / (top - bottom)))
      0 0 (-(2 / (far - near)))  (- ((far + near) / (far - near)))
      0 0 0 1
   ])
end

@export function perspective(fov::Real, aspect::Real, near::Real, far::Real)
   α = tan(deg2rad(fov) / 2)
   Mat4([
      (1 / (aspect * α)) 0 0 0
      0 (1 / α) 0 0
      0 0 (-((far + near) / (far - near))) (-((2far * near) / (far - near)))
      0 0 -1 0
   ])
end

end # module