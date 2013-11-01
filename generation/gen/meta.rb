module Gen::Meta
  def type(node)
    node.xpath("./definition/type/code").first.try(:[], :value)
  end

  def path(node)
    node.xpath("./path").first.try(:[], :value)
  end

  def attributes(db, path)
    db.each_with_object({}) {|(p,v), acc|
      acc[p] = v if p.start_with?(path)
    }
  end

  def attr(node, attr)
    node.xpath("./#{attr}").first[:value]
  end
  extend self
end
