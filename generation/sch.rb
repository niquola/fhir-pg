require 'nokogiri'
require 'active_support/core_ext'
require 'dt'

module Sch
  # requires
  def m
    Gen::Meta
  end

  def dt
    Dt
  end

  #public

  def load_profile(name)
    Gen::Db.parse_doc(Gen::Pth.from_root_path("vendor/#{name}.xml")).root
  end

  def meta(struct_el)
    els = struct_el.xpath('./element')
    res_name = resource_name(struct_el)
    collect_meta(res_name, els)
  end

  private

  def collect_meta(path, els)
    {
      name: path,
      path: path,
      attrs: collect_attrs(path, els),
    }
  end

  def nname(name)
    name.to_s.underscore
  end

  def resource_name(el)
    nname(el.xpath('./type').first[:value])
  end

  def table_name(path)
    path.gsub('.','_').underscore.pluralize
  end

  def collect_meta_for_complex_type(path, type)
    dt.mount(path, type)
  end

  def complex_type_attrs(path, ct_el)
    ct_el.xpath('.//element').map do |el|
      name = el[:name]
      {
        name: name,
        path: "#{path}.#{name}"
      }
    end
  end

  def collect_attrs(parent_name, els)
    els.each_with_object({}) do |el, res|
      next unless m.direct_parent?(parent_name, el)
      next if m.technical?(el)
      at = attrs(el, els)
      res[nname(at[:name]).to_sym] = at
    end
  end

  def el_name(el)
    Gen::Meta.path(el).split('.').last.gsub('[x]','').underscore
  end

  def attrs(el, els)
    types = m.types(el)
    type = types.size == 1 ? types.first : types
    attrs = {
      name: el_name(el),
      path: m.path(el),
      kind: m.kind(el),
      required: m.required?(el),
      collection:  m.collection?(el),
      type: type
    }
    case m.kind(el)
    when :complex_type
      attrs.reverse_merge! collect_meta_for_complex_type(m.path(el), m.type(el))
    when :nested_type
      attrs.reverse_merge! collect_meta(m.path(el), els)
    end
    attrs
  end

  extend self
end
