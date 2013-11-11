require_relative 'gen_spec_helper'
require 'uuid'

DB.extension(:pg_array, :pg_row)
Sequel.extension :pg_array_ops, :pg_row_ops
describe Gen do
  include SpecHelpers
  include described_class

  def sg
    SqlGen
  end

  def arr(args)
    Sequel.pg_array(args)
  end

  let(:meta) { Sch.meta(Sch.load_profile('pt')) }
  let(:pt) { JSON.parse(File.read(File.dirname(__FILE__) + '/patient-example.json')) }
  let(:pt2) { JSON.parse(File.read(File.dirname(__FILE__) + '/patient-example-f001-pieter.json')) }

  example do
    sql = ''
    sql<< "drop schema if exists fhir cascade;\n"
    sql<< "create schema fhir;\n"
    sql<<  sg.generate_sql(meta)
    DB.execute(sql)
    # puts pt.to_yaml
    id = insertit(pt, meta)
    id2 = insertit(pt2, meta)
    p id
    sql =  build_sql(meta)
    puts sql
    res =  DB[sql].all
    puts JSON.parse(res.first.values.first).to_yaml
    pt1, pt2 =  JSON.parse(res.first.values.first)

    puts pt1['name']
    puts pt2['name']
  end

  def column?(m)
    m.present? && [:primitive, :enum].include?(m[:kind])
  end

  def table?(m)
    m.present? && [:complex_type, :nested_type, :polimorphic].include?(m[:kind])
  end

  def get_ds(meta)
    name = 'fhir__' + meta[:path].gsub('.','_').underscore.pluralize
    (@ds ||= {})[name]||= DB[name.to_sym]
  end

  def table_name(meta)
    'fhir.' + meta[:path].gsub('.','_').underscore.pluralize
  end

  def ident(str, deep)
    str.split("\n").map{|l| "#{' '*4*deep}#{l}"}.join("\n")
  end

  def build_sql(meta, parent_table = nil, deep = 0)
    t = next_table_name

    sel = meta[:attrs].values.map do |m|
      next unless table?(m)
      "( #{build_sql(m, t, deep + 1)} ) as #{m[:name]}"
    end.compact.join(",\n")

    pth = meta[:path].split('.')
    root_name = pth.first.underscore

    root_cnd = ''
    if pth.size > 1
      root_cnd = "\nwhere #{t}.#{root_name}_id = t1.id"
    end
    parent_cnd = ''
    if pth.size > 2
      parent_name = pth[0..-2].join('_').underscore
      parent_cnd = "AND #{t}.#{parent_name.singularize}_id = #{parent_table}.id"
    end

    columns = meta[:attrs].values.map do |m|
      next if table?(m)
      next unless m[:name].present?
      "#{t}.#{m[:name]}"
    end.compact.join(',')

    <<-SQL
select array_to_json(array_agg(row_to_json(#{t}, true)), true) from
(
  select #{columns}#{sel.present? ? "#{columns.present? ? ',' : ''}\n  #{ident(sel, deep + 1)}" : ''}
  from #{table_name(meta)} #{t} #{root_cnd} #{parent_cnd}
) #{t}
SQL
  end

  def prev(t)
    't' + (t.gsub('t','').to_i - 1).to_s
  end

  def next_table_name
    @counter ||= 0
    @counter += 1
    "t#{@counter}"
  end

  def select_recur(meta)
  end

  def insertit(obj, meta, opts = {})
    obj = obj.each_with_object({}).each do |(attr_name, val), acc|
      acc[attr_name.underscore] = val
    end

    ins = meta[:attrs].each_with_object({}) do |(name, m), acc|
      next if ['resource_type', 'text'].include?(name)
      next unless column?(m)
      next unless val = obj[name.to_s]
      acc[name] = val.is_a?(Array) ? arr(val) : val
    end
    id = UUID.generate
    get_ds(meta).insert(ins.merge(id: id ).merge(opts))

    pth = meta[:path].split('.')
    root_name = "#{pth.first.underscore}_id"
    new_opts = {}
    new_opts[root_name] = opts[root_name] || id
    if pth.size > 1
      new_opts[pth.join('_').underscore.singularize + '_id'] = id
    end

    meta[:attrs].each_with_object({}) do |(name, m), acc|
      next if ['resource_type', 'text'].include?(name)
      next unless table?(m)
      next unless val = obj[name.to_s]
      (val.is_a?(Array) ? val : [val]).each do |v|
        insertit(v, m, new_opts)
      end
    end
    id
  end
end
