using Glutils.Math

title = "Basic Example"
background = "#112"
vsync = false

struct Vertex
   position::Vec{2}
   color::Vec{3}
end

const vertices = @SVector [
  Vertex([ 0.5,  0.5], [0, 0, 1]),
  Vertex([ 0.5, -0.5], [1, 1, 0]),
  Vertex([-0.5, -0.5], [1, 0, 0]),
  Vertex([-0.5,  0.5], [0, 1, 0]) 
]

const indices = @SVector Cuint[
   0, 1, 3,
   1, 2, 3
]

vao = createvao()
ibo, vbo = createbuffers(2)

glVertexArrayElementBuffer(vao, ibo)
glVertexArrayVertexBuffer(vao, 0, vbo, 0, sizeof(Vertex))

bufferdata!(ibo, indices,  :static_draw)
bufferdata!(vbo, vertices, :static_draw)
attrformat!(vao, 0, Vertex)

program = create_program(
   create_shader("shaders/simple.vert"),
   create_shader("shaders/simple.frag"),
)

function onupdate(dt)
   bindvao!(vao)
   bindprogram!(program)

   left, right  = -10, 10
   bottom, top  = -10, 10
   near, far = 0.0001, 10000

   eye = Vec(0, 0, 20)
   center = Vec(0, 0, 0)
   up = Vec(0, 1, 0)

   @uniforms program {
      uTime  = t
      uView  = lookAt(eye, center, up)
      uModel = scale(10) * rotateZ(2t / π)
      uProj  = ortho(left, right, bottom, top, near, far)
   }

   draw_elements(6, Cuint)
end