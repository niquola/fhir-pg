require 'dt'
module Gen::Meta
  def nname(name)
    name.to_s
    .underscore
  end

  def type(el)
    types(el).first
  end

  def types(el)
    el.xpath("./definition/type/code").map do |c|
      nname(c[:value])
    end.compact
  end

  def union_type?(el)
    types(el).size > 1
  end

  def path(el)
    pth = el.xpath("./path").first.try(:[], :value)
    pth.underscore if pth
  end

  def resource_ref?(el)
    type(el).match(/^resource\(/)
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

  def kind(el)
    types = types(el)
    return :nested_type if types.empty?
    return :polimorphic if union_type?(el)
    return :resource_ref  if resource_ref?(el)
    tp =  Dt.types[type(el)]
    return tp[:kind]   if tp && tp[:kind]
    raise "Ups what kind is #{el.inspect}?"
  end

  def direct_parent?(ppath, el)
    path = path(el)
    path.underscore.start_with?(ppath.underscore) && (path.split('.') - ppath.split('.')).size == 1
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
