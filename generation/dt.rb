require 'nokogiri'
require 'active_support/core_ext'

module Dt
  def nname(name)
    name.to_s
    .underscore
  end

  def datatypes_doc
    @datatypes_doc = Gen::Db.parse_doc(Gen::Pth.from_root_path("vendor/fhir-base.xsd"))
  end

  def datatypes
    (datatypes_doc.xpath('//simpleType') + datatypes_doc.xpath('//complexType'))
  end

  def types
    @types ||= build_types
  end

  #ALGORITHM

  def build_types
    {}.tap do |types|
      initial_types.each do |name, tp|
        next if name =~ /(_primitive|_list)$/
        types[name] = tp.dup
        types[name][:kind] = :complex_type unless tp[:attrs].empty?
      end

      initial_types.each do |name, tp|
        if name =~ /_primitive$/
          types[name.gsub('_primitive','')][:kind] = :primitive
        elsif name =~ /_list$/
          types[name.gsub('_list','')]
          .merge!(kind: :enum, options: tp[:options])
        end
      end
      expand_complex_types(types)
    end
  end

  def initial_types
    @initial_types ||= datatypes.each_with_object({}) do |el, acc|
      name = nname(el[:name])
      acc[name] = {
        name: name,
        type: name,
        options: el.xpath('.//enumeration').map{|n| n[:value]}.compact.sort,
        attrs: collect_attrs(name, el),
      }
    end
  end

  def collect_attrs(name, el)
    el.xpath('.//element')
    .each_with_object({}) do |cel, acc|
      cname = nname(cel[:name])
      acc[cname.to_sym] = {
        name: cname,
        path: "#{name}.#{cname}",
        type: nname(cel[:type]),
        requied: cel[:minOccurs] != '0',
        collection: cel[:maxOccurs] == 'unbounded'
      }
    end
  end

  #END OF ALGORITHM

  def expand_complex_types(types)
    types.each do |name, tp|
      tp[:attrs].each do |aneme, el|
        expand_recursive(el, types)
      end
    end
  end

  def expand_recursive(el, types)
    #fix kind
    tp = types[el[:type]]
    el[:kind] = tp.try(:[],:kind) || :primitive

    return unless tp[:attrs].present?

    #make it recursive
    el[:attrs] = tp[:attrs]
    .each_with_object({}) do |(name, scol), acc|
      expand_recursive(acc[name] = scol.dup.merge(
        path: "#{el[:path]}.#{scol[:name]}"
      ), types)
    end
  end

  def mount(path, type)
    raise "Could not find #{type}" unless tp = types[type]
    tp.dup.tap do |t|
      t[:path] = path
      mount_cols(path, t, :attrs)
    end
  end

  def mount_cols(path, t, what)
    return unless t[what]
    t[what] = t[what]
    .each_with_object({}) do |(name,col), acc|
      acc[nname(name).to_sym] = mount_recur(path, col.dup)
    end
  end

  def mount_recur(ppath, el)
    el.dup.tap do |new_el|
      path = "#{ppath}.#{nname(el[:name])}"
        new_el[:path] = path
      mount_cols(path, new_el, :attrs)
    end
  end



  def kind(type)
    return :primitive if primitives[type]
    return :enum if enums[type]
    :complex_type
  end

  extend self
end
