const ProgramParamMap = Dict(
   :delete_status                         => GL_DELETE_STATUS,
   :link_status                           => GL_LINK_STATUS,
   :validate_status                       => GL_VALIDATE_STATUS,
   :info_log_length                       => GL_INFO_LOG_LENGTH,
   :attached_shaders                      => GL_ATTACHED_SHADERS,
   :active_atomic_counter_buffers         => GL_ACTIVE_ATOMIC_COUNTER_BUFFERS,
   :active_attributes                     => GL_ACTIVE_ATTRIBUTES,
   :active_attribute_max_length           => GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
   :active_uniforms                       => GL_ACTIVE_UNIFORMS,
   :active_uniform_blocks                 => GL_ACTIVE_UNIFORM_BLOCKS,
   :active_uniform_block_max_name_length  => GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH,
   :active_uniform_max_length             => GL_ACTIVE_UNIFORM_MAX_LENGTH,
   :program_binary_length                 => GL_PROGRAM_BINARY_LENGTH,
   :transform_feedback_buffer_mode        => GL_TRANSFORM_FEEDBACK_BUFFER_MODE,
   :transform_feedback_varyings           => GL_TRANSFORM_FEEDBACK_VARYINGS,
   :transform_feedback_varying_max_length => GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH,
   :geometry_vertices_out                 => GL_GEOMETRY_VERTICES_OUT,
   :geometry_input_type                   => GL_GEOMETRY_INPUT_TYPE,
   :geometry_output_type                  => GL_GEOMETRY_OUTPUT_TYPE,
)

const ShaderParamMap = Dict(
   :type                 => GL_SHADER_TYPE,
   :compile_status       => GL_COMPILE_STATUS,
   :delete_status        => GL_DELETE_STATUS,
   :info_log_length      => GL_INFO_LOG_LENGTH,
   :shader_source_length => GL_SHADER_SOURCE_LENGTH
)

const ShaderTypeMap = Dict(
   :vertex     => GL_VERTEX_SHADER,
   :vert       => GL_VERTEX_SHADER,
   :fragment   => GL_FRAGMENT_SHADER,
   :frag       => GL_FRAGMENT_SHADER,
   :geometry   => GL_GEOMETRY_SHADER,
   :geom       => GL_GEOMETRY_SHADER,
   :compute    => GL_COMPUTE_SHADER,
   :comp       => GL_COMPUTE_SHADER,
)

const BufferTypeMap = Dict(
   :array               => GL_ARRAY_BUFFER,
   :atomic_counter      => GL_ATOMIC_COUNTER_BUFFER,      
   :copy_read           => GL_COPY_READ_BUFFER,
   :copy_write          => GL_COPY_WRITE_BUFFER,   
   :dispatch_indirect   => GL_DISPATCH_INDIRECT_BUFFER,         
   :draw_indirect       => GL_DRAW_INDIRECT_BUFFER,
   :element_array       => GL_ELEMENT_ARRAY_BUFFER,
   :pixel_pack          => GL_PIXEL_PACK_BUFFER,   
   :pixel_unpack        => GL_PIXEL_UNPACK_BUFFER,   
   :query               => GL_QUERY_BUFFER,
   :shader_storage      => GL_SHADER_STORAGE_BUFFER,
   :texture             => GL_TEXTURE_BUFFER,
   :transform_feedback  => GL_TRANSFORM_FEEDBACK_BUFFER,
   :uniform             => GL_UNIFORM_BUFFER,
)

const BufferUsageMap = Dict(
   :static_draw  => GL_STATIC_DRAW,
   :static_copy  => GL_STATIC_COPY,
   :static_read  => GL_STATIC_READ,
   :stream_draw  => GL_STREAM_DRAW,
   :stream_copy  => GL_STREAM_COPY,
   :stream_read  => GL_STREAM_READ,
   :dynamic_draw => GL_DYNAMIC_DRAW,
   :dynamic_copy => GL_DYNAMIC_COPY,
   :dynamic_read => GL_DYNAMIC_READ,
)

const DebugSource = Dict(
   GL_DEBUG_SOURCE_API => "API",
   GL_DEBUG_SOURCE_WINDOW_SYSTEM => "Window",
   GL_DEBUG_SOURCE_SHADER_COMPILER => "Shader Compiler",
   GL_DEBUG_SOURCE_THIRD_PARTY => "Third Party",
   GL_DEBUG_SOURCE_APPLICATION => "Application",
   GL_DEBUG_SOURCE_OTHER => "Unknown"
)

const DebugType = Dict(
   GL_DEBUG_TYPE_ERROR => "Error",
   GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR => "Deprecated Behavior",
   GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR => "Undefined Behavior",
   GL_DEBUG_TYPE_PORTABILITY => "Portability",
   GL_DEBUG_TYPE_PERFORMANCE => "Performance",
   GL_DEBUG_TYPE_OTHER => "Other",
   GL_DEBUG_TYPE_MARKER => "Marker",
)

const DebugSeverity = Dict(
   GL_DEBUG_SEVERITY_HIGH => "high",
   GL_DEBUG_SEVERITY_MEDIUM => "medium",
   GL_DEBUG_SEVERITY_LOW => "low",
   GL_DEBUG_SEVERITY_NOTIFICATION => "notification",
)