@export function createvaos(n::Int = 1)
   @assert n > 0 "Number of Vertex Arrays to create must be greater than 0"
   ids = Vector{Cuint}(undef, n)
   @c glCreateVertexArrays(1, ids)
   return ids
end

@export function genvaos(n::Int = 1)
   @assert n > 0 "Number of Vertex Arrays to generate must be greater than 0"
   ids = Vector{Cuint}(undef, n)
   @c glGenVertexArrays(1, ids)
   return ids
end

@export createvao() = bindvao!(createvaos() |> first)
@export genvao() = bindvao!(genvaos() |> first)
@export bindvao!(vao::Cuint) = (glBindVertexArray(vao); vao)
@export deletevaos!(ids::Cuint...) = glDeleteVertexArrays(length(ids), collect(ids))

@export function genbuffers(n::Int = 1)
   @assert n > 0 "Number of buffers to generate must be greater than 0"
   ids = Vector{Cuint}(undef, n)
   @c glGenBuffers(1, ids)
   return ids
end
   
@export function createbuffers(n::Int = 1)
   @assert n > 0 "Number of buffers to create must be greater than 0"
   ids = Vector{Cuint}(undef, n)
   @c glCreateBuffers(n, ids)
   return ids
end

@export genbuffer() = genbuffers() |> first
@export createbuffer() = createbuffers() |> first
@export deletebuffers!(ids::Cuint...) = glDeleteBuffers(length(ids), collect(ids))

"""
      bindbuffer!(buffer, type)

Binds a `buffer` with the respective `type`.

`type` can be one of the following:

```julia
:array              -> GL_ARRAY_BUFFER
:atomic_counter     -> GL_ATOMIC_COUNTER_BUFFER
:copy_read          -> GL_COPY_READ_BUFFER
:copy_write         -> GL_COPY_WRITE_BUFFER
:dispatch_indirect  -> GL_DISPATCH_INDIRECT_BUFFER
:draw_indirect      -> GL_DRAW_INDIRECT_BUFFER
:element_array      -> GL_ELEMENT_ARRAY_BUFFER
:pixel_pack         -> GL_PIXEL_PACK_BUFFER
:pixel_unpack       -> GL_PIXEL_UNPACK_BUFFER
:query              -> GL_QUERY_BUFFER
:shader_storage     -> GL_SHADER_STORAGE_BUFFER
:texture            -> GL_TEXTURE_BUFFER
:transform_feedback -> GL_TRANSFORM_FEEDBACK_BUFFER
:uniform            -> GL_UNIFORM_BUFFER
```
"""
@export function bindbuffer!(buffer::Cuint, type::Symbol)
   sym = Symbol(uppercase("GL_$(type)_BUFFER"))
   @assert isdefined(ModernGL, sym) "Unrecognized buffer type: $sym"
   type = getfield(ModernGL, sym)
   glBindBuffer(type, buffer)
end

@export function bufferdata!(buffer::Cuint, size::Integer, data::T, usage::Symbol) where {T}
   @assert usage in keys(BufferUsageMap) "Unrecognized buffer usage: $usage"
   glNamedBufferData(buffer, size, data, BufferUsageMap[usage])
end

function bufferdata!(buffer::Cuint, data::AbstractArray{T}, usage::Symbol) where {T}
   size = length(data) * sizeof(T) 
   bufferdata!(buffer, size, data, usage)
end

function bufferdata!(size::Integer, data::T, usage::Symbol; target::Symbol) where {T}
   @assert usage in keys(BufferUsageMap) "Unrecognized buffer usage: $usage"
   glBufferData(target, size, data, BufferUsageMap[usage])
end

function bufferdata!(data::AbstractArray{T}, usage::Symbol; target::Symbol) where {T}
   size = length(data) * sizeof(T) 
   bufferdata!(size, data, usage; target)
end

@export function attrformat!(
   vao::Cuint,
   index::Integer, 
   size::Integer, 
   type::DataType, 
   normalized::Bool, 
   offset::Integer
)
   glVertexArrayAttribFormat(vao, index, size, gtype(type), gbool(normalized), offset)
end

function attrformat!(vao::Cuint, binding::Integer, ::Type{T}) where {T}
   for i in 1:fieldcount(T)
      type = fieldtype(T, i)
      offset = fieldoffset(T, i)
      size = type <: SVector{N} where {N} ? length(type) : 1
      attrformat!(vao, i - 1, size, type, false, offset)
      glVertexArrayAttribBinding(vao, i - 1, binding)
      glEnableVertexArrayAttrib(vao, i - 1)
   end
end

@export function draw_elements(mode::GLenum, count::Integer, type::DataType, indices::Ptr = Ptr{Cvoid}(0))
   glDrawElements(mode, count, gtype(type), indices)
end

function draw_elements(count::Integer, type::DataType, indices::Ptr = Ptr{Cvoid}(0))
   glDrawElements(GL_TRIANGLES, count, gtype(type), indices)
end