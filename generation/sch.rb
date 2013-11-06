require 'nokogiri'
require 'active_support/core_ext'
require 'dt'

module Sch
  def m
    Gen::Meta
  end

  def load_profile(name)
    Gen::Db.parse_doc(Gen::Pth.from_root_path("vendor/#{name}.xml")).root
  end

  def resource_name(el)
    el.xpath('./type').first[:value]
  end

  def table_name(path)
    path.gsub('.','_').underscore.pluralize
  end

  def meta(struct_el)
    els = struct_el.xpath('./element')
    res_name = resource_name(struct_el)
    collect_meta(res_name, els)
  end

  def collect_meta(path, els)
    {
      table: table_name(path),
      columns: collect_columns(path, els),
      referenced_by: collect_references(path, els)
    }
  end

  def collect_meta_for_complex_type(path, type)
    Dt.mount(path, type)
  end

  def complex_type_columns(path, ct_el)
    ct_el.xpath('.//element').map do |el|
      name = el[:name]
      {
        name: name,
        path: "#{path}.#{name}"
      }
    end
  end

  def collect_references(parent_name, els)
    res = {}
    direct_children(parent_name, els) do |el|
      next unless m.compound_type?(el)
      next unless m.collection?(el)
      at = attrs(el, els)
      res[at[:name].to_sym] = at
    end
    res
  end

  def collect_columns(parent_name, els)
    res = {}
    direct_children(parent_name, els) do |el|
      next unless m.primitive?(el) || ( !m.collection?(el) && m.compound_type?(el))
      at = attrs(el, els)
      res[at[:name].to_sym] = at
    end
    res
  end

  def el_name(el)
    Gen::Meta.path(el).split('.').last.gsub('[x]','').underscore
  end

  def direct_children(parent_name, els)
    els.select{|el| m.direct_parent?(parent_name, el) && !m.technical?(el)}
    .map do |el|
      yield el
    end.compact
  end

  def attrs(el, els)
    attrs = {
      name: el_name(el),
      path: m.path(el),
      kind: m.kind(el),
    }
    attrs[:required] = true if m.required?(el)
    attrs[:collection] = true if m.collection?(el)
    type = m.union_type?(el) ? m.types(el) : m.types(el).first
    attrs[:type] = type if type.present?
    case m.kind(el)
    when :complex_type
      attrs.merge! collect_meta_for_complex_type(m.path(el), m.type(el))
    when :nested_type
      attrs.merge! collect_meta(m.path(el), els)
    end
    attrs
  end

  extend self
end
