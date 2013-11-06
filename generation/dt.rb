require 'nokogiri'
require 'active_support/core_ext'

module Dt
  def datatypes_doc
    @datatypes_doc = Gen::Db.parse_doc(Gen::Pth.from_root_path("vendor/fhir-base.xsd"))
  end

  def datatypes
    @datatypes ||= {}.tap do |res|
      datatypes_doc.xpath('//simpleType').each do |el|
        res[el[:name]] = el
      end

      datatypes_doc.xpath('//complexType').each do |el|
        res[el[:name]]= el
      end
    end
  end

  def types
    @types ||= {}.merge(primitives).merge(enums).merge(complex_types)
  end

  def mount(path, type)
    types[type].dup.tap do |t|
      t[:path] = path
      (t[:columns] || {}).each do |_,col|
        mount_recur(path, col)
      end
      (t[:referenced_by] || {}).each do |_,col|
        mount_recur(path, col)
      end
    end
  end

  def mount_recur(ppath, el)
    path = "#{ppath}.#{el[:name]}"
    el[:path] = path
    (el[:columns] || []).each do |name, col|
      mount_recur(path, col)
    end
    (el[:referenced_by] || []).each do |name, col|
      mount_recur(path, col)
    end
  end

  def primitives
    primitives_els.each_with_object({}) do |(name,_), acc|
      acc[name] = {
        type: name,
        kind: :primitive
      }
    end
  end

  def primitives_els
    @primitives = datatypes.each_with_object({}) do |(name,el),acc|
      if name =~ /-primitive$/
        acc[name.gsub('-primitive','')] = el
      end
    end
  end

  def enums
    enums_els.each_with_object({}) do |(name,el), acc|
      acc[name] = {
        type: name,
        kind: :enum,
        options: el.xpath('.//enumeration').map{|n| n[:value]}.compact.sort
      }
    end
  end

  def enums_els
    @enums = datatypes.each_with_object({}) do |(name,el),acc|
      if name =~ /-list$/
        acc[name.gsub('-list','')] = el
      end
    end
  end

  def complex_types
    @complex_types ||= begin
                         cts = complex_types_els.each_with_object({}) do |(name,el), acc|
                           acc[name] = {
                             type: name,
                             kind: :complex_type,
                             columns: collect_columns(name, el),
                           }
                           refs = collect_refs(name, el)
                           acc[name][:referenced_by] = refs unless refs.empty? 
                         end
                         expand_complex_types(cts)
                       end
  end

  def expand_complex_types(cts)
    cts.each do |name, ct|
      if ct[:kind] == :complex_type
        if ct[:columns].present?
          ct[:columns].each do |n, col|
            expand_recursive(col, cts, :columns)
          end
        end
        if ct[:referenced_by].present?
          ct[:referenced_by].each do |n, col|
            expand_recursive(col, cts, :referenced_by)
          end
        end
      end
    end
    cts
  end

  def expand_recursive(col, cts, what)
    return unless col[:kind] == :complex_type
    return unless col[:type].present?
    attrs = cts[col[:type]].dup
    return unless attrs.present?
    return unless attrs[what].present?
    attrs[what] = attrs[what]
    .each_with_object({}) do |(name, scol), acc|
      at = scol.dup
      at[:path] = "#{col[:path]}.#{scol[:name]}"
        acc[name] = at
    end
    col.reverse_merge!(attrs)
    col[what].each do |name, scol|
      expand_recursive(scol, cts, what)
    end
  end

  def complex_types_els
    @compound_types = datatypes.each_with_object({}) do |(name,el),acc|
      next unless name
      next if name =~ /-primitive$/
      next if name =~ /-list$/
      next if primitives.key?(name)
      next if enums.key?(name)
      acc[name] = el
    end
  end


  def collect_columns(name, el)
    el.xpath('.//element').each_with_object({}) do |cel, acc|
      next if cel[:maxOccurs] == 'unbounded'
      acc[cel[:name].try(:to_sym)] = build_column(name, cel)
    end
  end

  def collect_refs(name, el)
    el.xpath('.//element').each_with_object({}) do |cel, acc|
      next unless cel[:maxOccurs] == 'unbounded'
      acc[cel[:name].try(:to_sym)] = build_column(name, cel)
    end
  end

  def build_column(parent_name, el)
    name = el[:name]
    type = el[:type]
    kind = kind(type)
    {
      name: name,
      path: "#{parent_name}.#{name}",
      type: type,
      kind: kind,
      requied: el[:minOccurs] != '0',
      collection: el[:maxOccurs] == 'unbounded',
    }
  end

  def kind(type)
    return :primitive if primitives[type]
    return :enum if enums[type]
    :complex_type
  end

  extend self
end
