require_relative 'gen_spec_helper'

describe Gen do
  include described_class

  def attribute_type(db, el)
    m = Gen::Meta
    types = m.types(el)
    if types.empty?
      :nested_type
    elsif types.size == 1
      if db.datatypes["#{types.first}-primitive"]
        :primitive
      else
        :complex_type
      end
    else types.size == 1
      :union
    end
  end

  def el_types(el)
    el.xpath("./definition/type/code").map do |c|
      c[:value]
    end.compact
  end

  def el_name(el)
    Gen::Meta.path(el).split('.').last.gsub('[x]','').underscore
  end


  def collect_attributes(parent_name, struct_el)
    attributes(parent_name, struct_el.xpath('./element'))
  end

  def attributes(parent_name, elements)
    m = Gen::Meta
    elements.map do |el, acc|
      next unless m.direct_parent?(parent_name, el)
      next if m.technical?(el)
      {
        name: el_name(el),
        path: m.path(el),
        type: m.union_type?(el) ? m.types(el) : m.types(el).first,
        kind: m.kind(el),
        collection: m.collection?(el),
        attributes: attributes(m.path(el), elements)
      }
    end.compact
  end

  SCHEMA = 'fhir'

  example do
    db = Gen::Db
    res = db.resources
    .each_with_object({}) do |(resource, el), acc|
      acc[resource] = {
        name: resource,
        type: :resource,
        path: resource,
        attributes: collect_attributes(resource, el)
      }
    end
    open(File.dirname(__FILE__) + '/tmp.yaml','w') {|f| f<< res['Patient'].to_yaml}
    puts Gen::Schema.generate(res['Patient'])
  end
end
