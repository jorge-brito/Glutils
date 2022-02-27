const GLTypeMap = Dict(
   GL_BOOL           => Bool,
   GL_BYTE           => Cchar,
   GL_SHORT          => Cshort,
   GL_INT            => Cint,
   GL_FLOAT          => Cfloat,
   GL_DOUBLE         => Cdouble,
   GL_UNSIGNED_BYTE  => Cuchar,
   GL_UNSIGNED_SHORT => Cushort,
   GL_UNSIGNED_INT   => Cuint,
)

for (enum, T) in GLTypeMap
   @eval gtype(::Type{$T}) = $(enum)
end

@export begin
   function genum(type::GLenum)
      if type in keys(GLTypeMap)
         return GLTypeMap[type]
      else 
         error("No DataType found for $type") 
      end
   end
   
   gtype(::Type{SVector{N, T}}) where {N, T} = gtype(T)
   gbool(x::Bool)    = x ? GL_TRUE : GL_FALSE
   gbool(x::GLenum)  = x == GL_TRUE
end