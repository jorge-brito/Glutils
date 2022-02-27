module Glutils

using CSyntax
using ModernGL
using StaticArrays
using InlineExports

include("utils.jl")
include("maps.jl")
include("types.jl")
include("debug.jl")
include("math.jl")
include("buffers.jl")
include("shaders.jl")

using .Math

@ignore include("../examples/renderer.jl")

end # module