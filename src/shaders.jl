@export function getshaderiv(shader::Cuint, name::GLenum)
   param::Cint = 0
   @c glGetShaderiv(shader, name, &param)
   return param
end

function getshaderiv(shader::Cuint, name::Symbol)
   @assert name in keys(ShaderParamMap) "Unrecognized shader parameter: $name"
   param = ShaderParamMap[name]
   return getshaderiv(shader, param)
end

@export shadertype(shader::Cuint)  = getshaderiv(shader, :type)
@export iscompiled(shader::Cuint)   = getshaderiv(shader, :compile_status) == GL_TRUE

@export function shaderinfo(shader::Cuint)
   len::Cint = 0
   maxlen = getshaderiv(shader, :info_log_length)
   message = StringArray(maxlen)
   @c glGetShaderInfoLog(shader, maxlen, &len, message)
   return String(message[1:len])
end

@export function getprogramiv(program::Cuint, name::GLenum)
   param::Cint = 0
   @c glGetProgramiv(program, name, &param)
   return param
end

function getprogramiv(program::Cuint, name::Symbol)
   @assert name in keys(ProgramParamMap) "Unrecognized program parameter: $name"
   param = ProgramParamMap[name]
   return getprogramiv(program, param)
end

@export islinked(program::Cuint) = getprogramiv(program, :link_status)     == GL_TRUE
@export isvalid(program::Cuint)  = getprogramiv(program, :validate_status) == GL_TRUE

@export function programinfo(program::Cuint)
   len::Cint = 0
   maxlen = getprogramiv(program, :info_log_length)
   message = StringArray(maxlen)
   @c glGetProgramInfoLog(program, maxlen, &len, message)
   return String(message[1:len])
end

@export function active_uniform(program::Cuint, index::Integer)
   buff_size = getprogramiv(program, :active_uniform_max_length)
   len::Cint = 0
   size::Cint = 0
   type::Cuint = 0
   _name = StringArray(buff_size)

   @c glGetActiveUniform(program, index, buff_size, &len, &size, &type, _name)

   name = String(_name[1:end-1])
   location = glGetUniformLocation(program, name)

   return name, location, type, size
end

@export function active_uniforms(program::Cuint)
   count = getprogramiv(program, :active_uniforms)
   return map(0:count-1) do index
      active_uniform(program, index)
   end
end

@export function active_attribute(program::Cuint, index::Integer)
   buff_size = getprogramiv(program, :active_attribute_max_length)
   len::Cint = 0
   size::Cint = 0
   type::Cuint = 0
   name = StringArray(buff_size)

   @c glGetActiveAttrib(program, index, buff_size, &len, &size, &type, name)

   return String(name[1:end-1]), size, type
end

@export function active_attributes(program::Cuint)
   count = getprogramiv(program, :active_uniforms)
   return map(0:count-1) do index
      active_attribute(program, index)
   end
end

@export function create_shader(type::Symbol, source::AbstractString; strict::Bool = true)
   @assert type in keys(ShaderTypeMap) "Unrecognized shader type '$type'"
   shader = glCreateShader(ShaderTypeMap[type])
   
   @c glShaderSource(shader, 1, Ptr{Cchar}[pointer(source)], C_NULL)
   glCompileShader(shader)

   if !iscompiled(shader) && strict
      info = shaderinfo(shader)
      glDeleteShader(shader)
      error("Failed to compile shader: $info")
   end

   return shader
end

function create_shader(filename::AbstractString, type::Symbol = :auto; strict::Bool = true)
   ext = extof(filename)
   source = read(filename, String)
   if ext != "" && type == :auto
      stype = Symbol(ext[2:end])

      @assert stype in keys(ShaderTypeMap) "
         Param `type` is set to auto, but could not automatically detect
         the type of the shader from the extension `$ext`.

         You can manually provide the shader type using the `type` parameter.
      "

      return create_shader(stype, source; strict)
   else
      return create_shader(type, source; strict)
   end
end

@export function create_program(shaders::Cuint...; strict::Bool = true)
   program = glCreateProgram()

   if length(shaders) > 0
      foreach(shaders) do shader
         glAttachShader(program, shader)
      end
      
      glLinkProgram(program)
      glValidateProgram(program)
   
      if strict && !islinked(program)
         info = programinfo(program)
         deleteshaders!(shaders...)
         glDeleteProgram(program)
         error("Failed to link program: $info")
      end
   
      if strict && !isvalid(program)
         info = programinfo(program)
         deleteshaders!(shaders...)
         glDeleteProgram(program)
         error("Failed to validate program: $info")
      end
   
      foreach(shaders) do shader
         glDetachShader(program, shader)
         glDeleteShader(shader)
      end
   end

   return program
end

@export bindprogram!(program::Cuint) = glUseProgram(program)
@export deleteshaders!(shaders::Cuint...) = foreach(glDeleteShader, shaders)
@export deleteprograms!(programs::Cuint...) = foreach(glDeleteProgram, programs)

_suffix(::Type{<:Signed}) = "i" 
_suffix(::Type{<:Unsigned}) = "ui" 
_suffix(::Type{<:AbstractFloat}) = "f" 

@export function uniform(program::Cuint, name::StringLike)
   return glGetUniformLocation(program, string(name))
end

@export function uniforms(program::Cuint, names::StringLike...)
   return map(names) do name
      uniform(program, name)
   end
end

@export macro uniform(expr)
   @assert Meta.isexpr(expr, :(=)) "Wrong usage of @uniform macro"
   
   left, value = expr.args
   @assert Meta.isexpr(left, :(.)) "Wrong usage of @uniform macro"
   
   program, name = left.args
   
   :( uniform!(uniform($program, $name), $value) ) |> esc
end

@export macro uniforms(program, block)
   exprs = map(block.args) do expr
      if Meta.isexpr(expr, :(=))
         name, value = expr.args
         return :(@uniform $(program).$(name) = $(value))
      end
      return expr
   end

   quote
      bindprogram!($(program))
      $(exprs...)
   end |> esc
end


@export function uniform!(location::Cint, vec::SVector{N, T}) where {T <: Real, N}
   @assert location > -1  "Attemping to set value of uniform with negative location: $location"
   @assert 4 >= N >= 1 "Expected uniform vector to have 1-4 dimensions, got $N"
   fname = Symbol("glUniform$N" * _suffix(T))
   getfield(ModernGL, fname)(location, vec...)
end

uniform!(location::Cint, values::Real...) = uniform!(location, SVector(values...))
uniform!(location::Cint, vec::Vector{<:Real}) = uniform!(location, SVector(vec...))

function uniform!(location::Cint, matrix::SMatrix{N, M}; transpose = false) where {N, M}
   @assert location > -1 "Attemping to set value of uniform with negative location: $location"
   @assert 4 >= N >= 1 "Expected uniform matrice to have 1-4 columns, got $N"
   @assert 4 >= M >= 1 "Expected uniform matrice to have 1-4 rows, got $M"

   suffix = N == M ? "$(N)fv" : "$(N)x$(M)fv"
   fname = Symbol("glUniformMatrix$suffix")
   getfield(ModernGL, fname)(location, 1, gbool(transpose), matrix)
end