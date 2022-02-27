using GLFW
using Colors
using Glutils
using CSyntax
using ModernGL
using StaticArrays

macro ignore(args...) end

@ignore begin
   include("basic.jl")
end

if isempty(ARGS)
   error("Missing obrigatory argument <example>.

      Usage: julia renderer.jl <example>
   ")
end

example = first(ARGS)

title  = "Example"
width  = 800
height = 800
background = "#4e26ff"

const window = Ref{GLFW.Window}()

var"@size"(args...)   = :( collect(GLFW.GetFramebufferSize(window[])) )
var"@width"(args...)  = :( first(@size) )
var"@height"(args...) = :( last(@size) )
var"@window"(args...) = :( window[] )

GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 4)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 6)
GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true)
GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT , true)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)

window[] = GLFW.CreateWindow(width, height, title)
GLFW.MakeContextCurrent(window[])

ondebug_msg() do info::GLDebugInfo
   type, source, message, severity = info
   @error "$(message)" type source severity
end

include("$example.jl")

if @isdefined(vsync) && vsync
   GLFW.SwapInterval(1)
end

GLFW.SetWindowTitle(@window, title)
GLFW.SetWindowSize(@window, width, height)

then = time()
t = 0.0

try
   while !GLFW.WindowShouldClose(@window)
      GLFW.PollEvents()

      now = time()
      dt = now - then
      global then = now
      global t += dt

      bg = parse(RGBA, background)

      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glClearColor(bg.r, bg.g, bg.b, bg.alpha)
      glViewport(0, 0, (@size)...)
      
      onupdate(dt)
      
      GLFW.SwapBuffers(@window)
   end
catch err
   @error "Error on update callback" exception=err
   Base.show_backtrace(stderr, catch_backtrace())
finally
   if @isdefined(onclose)
      onclose()
   end
   GLFW.DestroyWindow(@window)
end