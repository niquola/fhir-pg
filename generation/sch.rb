require 'nokogiri'
require 'active_support/core_ext'

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
      referenced_by: collect_references(path, els),
      embeds: collect_embeded_types(path, els),
      custom_types: collect_custom_types(path, els),
    }
  end

  def collect_custom_types(parent_name, els)
    direct_children(parent_name, els) do |el|
      next unless m.compound_type?(el)
      next if m.collection?(el)
      attrs(el, els)
    end
  end

  def collect_references(parent_name, els)
    direct_children(parent_name, els) do |el|
      next unless m.compound_type?(el)
      next unless m.collection?(el)
      attrs(el, els)
    end
  end

  def collect_columns(parent_name, els)
    direct_children(parent_name, els) do |el|
      next unless m.primitive?(el)
      attrs(el, els)
    end
  end

  def collect_embeded_types(parent_name, els)
    direct_children(parent_name, els) do |el|
      next if m.collection?(el)
      next unless m.compound_type?(el)
      attrs(el, els)
    end
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
    if m.compound_type?(el)
      attrs.merge! collect_meta(m.path(el), els)
    end
    attrs
  end

  extend self
end
