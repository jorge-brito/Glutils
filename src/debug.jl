const DEBUG_ENABLED = Ref(false)
const DEBUG_CALLBACK = Ref{Function}()

@export struct GLDebugInfo <: Iterable
   type::String
   source::String
   message::String
   severity::String
end

function debug_message_callback(
   _source::GLenum, 
   _type::GLenum, 
   ::GLuint, 
   _severity::GLenum, 
   ::GLsizei, 
   _msg::Ptr{GLchar}, 
   ::Ptr{Cvoid}
)::Cvoid 
   message  = unsafe_string(_msg)
   source   = get(DebugSource, _source, "Unknown")
   type     = get(DebugType, _type, "Unknown")
   severity = get(DebugSeverity, _severity, "Unknown")

   if isassigned(DEBUG_CALLBACK)
      GLDebugInfo(
         type,
         source,
         message,
         severity,
      ) |> DEBUG_CALLBACK[]
   end

   return nothing
end

"""
      ondebug_msg(callback::Function)

Enables debugging of OpenGL functions and sets the OpenGL debug message `callback` function.

`callback` only accepts one parameter of type [`GLDebugInfo`](@ref), 
that contains the information about the debug message.
"""
@export function ondebug_msg(callback::Function)
   @assert hasmethod(callback, Tuple{GLDebugInfo}) "
      The `ondebug_msg` function expects a `callback` that accepts 
      a single parameter of type `GLDebugInfo` : `callback(info::GLDebugInfo)`
   "

   DEBUG_CALLBACK[] = callback
   
   if DEBUG_ENABLED[] == false
      DEBUG_ENABLED[] = true

      ptr_debug_callback = @cfunction(debug_message_callback, Cvoid, (
         GLenum,
         GLenum,
         GLuint,
         GLenum,
         GLsizei,
         Ptr{GLchar},
         Ptr{Cvoid}
      ))
   
      glEnable(GL_DEBUG_OUTPUT)
      glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS)
   
      GC.@preserve ptr_debug_callback begin
         glDebugMessageCallback(ptr_debug_callback, C_NULL)
         ids = Cuint(0)
         @c glDebugMessageControl(
            GL_DONT_CARE,
            GL_DONT_CARE,
            GL_DONT_CARE,
            0,
            &ids,
            GL_TRUE,
         )
      end
   end
end