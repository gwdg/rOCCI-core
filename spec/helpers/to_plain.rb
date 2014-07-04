require 'psych'

class ToPlain < Psych::Visitors::Visitor

  # Scalars are just strings.
  def visit_Psych_Nodes_Scalar o
    o.value
  end

  # Sequences are arrays.
  def visit_Psych_Nodes_Sequence o
    o.children.each_with_object([]) do |child, list|
      list << accept(child)
    end
  end

  # Mappings are hashes.
  def visit_Psych_Nodes_Mapping o
    o.children.each_slice(2).each_with_object({}) do |(k,v), h|
      h[accept(k)] = accept(v)
    end
  end

  # We also need to handle documents...
  def visit_Psych_Nodes_Document o
    accept o.root
  end

  # ... and streams.
  def visit_Psych_Nodes_Stream o
    o.children.map { |c| accept c }
  end

  # Aliases aren't handles here :-(
  def visit_Psych_Nodes_Alias o
    # Not implemented!
  end

end
