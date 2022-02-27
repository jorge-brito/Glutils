const StringLike = Union{AbstractString, Symbol}

macro ignore(args...) end

StringArray(length::Integer) = Vector{Cuchar}(undef, length)

function extof(path::AbstractString)
   m = match(r"\.\w+$", path)
   if !isnothing(m)
      return m.match
   else
      return ""
   end
end

@export macro offsetof(type, field)
   quote
      let fields = fieldnames($type)
         local index = findfirst(f -> f == $(QuoteNode(field)), fields)
         fieldoffset($type, index)
      end
   end |> esc
end

abstract type Iterable end

function Base.iterate(self::Iterable, state = 1) 
   if state > fieldcount(typeof(self))
      return nothing
   end

   return getfield(self, state), state + 1
end