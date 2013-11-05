module Gen::Meta
  def type(el)
    el.xpath("./definition/type/code").first.try(:[], :value).presence
  end

  def types(el)
    el.xpath("./definition/type/code").map do |c|
      c[:value]
    end.compact
  end

  def union_type?(el)
    types(el).size > 1
  end

  def path(el)
    el.xpath("./path").first.try(:[], :value)
  end

  def resource_ref?(el)
    type(el).match(/^Resource\(/)
  end

  def technical?(el)
    path(el) =~ /contained$/ || path(el) =~ /extension$/ || ['Extension', 'Narrative'].include?(type(el))
  end

  def collection?(el)
    attr(el, 'max') == '*'
  end

  def compound_type?(el)
    %w[nested_type complex_type].include?(kind(el).to_s)
  end

  def required?(el)
    attr(el, 'min') == '1'
  end

  def primitive?(el)
    types = types(el)
    Gen::Db.datatypes["#{types.first}-primitive"]
  end

  def kind(el)
    types = types(el)
    return :nested_type if types.empty?
    return :polimorphic if union_type?(el)
    return :resource_ref  if resource_ref?(el)
    return :primitive   if primitive?(el)
    :complex_type
  end

  def direct_parent?(ppath, el)
    path = path(el)
    path.start_with?(ppath) && (path.split('.') - ppath.split('.')).size == 1
  end

  def attributes(db, path)
    db.each_with_object({}) {|(p,v), acc|
      acc[p] = v if p.start_with?(path)
    }
  end

  def attr(el, attr)
    el.xpath("./definition/#{attr}").first[:value]
  end
  extend self
end
