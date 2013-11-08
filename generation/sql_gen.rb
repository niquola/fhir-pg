require 'tsort'
module SqlGen
  module SQL
    def to_sql(arr)
      arr.map do |item|
        case item[:sql]
        when :enum
          enum_to_sql(item)
        when :type
          type_to_sql(item)
        when :table
          table_to_sql(item)
        end
      end.join("\n")
    end

    private

    def enum_to_sql(item)
      "CREATE TYPE #{item[:name]} AS ENUM (#{item[:options].map{|o| "'#{o}'"}.join(",")});"
    end

    def columns_to_sql(item)
      item[:columns].values.map do |col|
        arr = col[:array] ? '[]' : ''
        [%Q["#{col[:name]}"], "#{col[:type]}#{arr}"].join(' ')
      end.join(",\n")
    end

    def type_to_sql(item)
      "CREATE TYPE #{item[:name]} AS (\n#{columns_to_sql(item)}\n);"
    end

    def table_to_sql(item)
      "CREATE TABLE #{item[:name]} (\n#{columns_to_sql(item)}\n);"
    end

    extend self
  end

  def generate_sql(meta)
    SQL.to_sql(generate(meta))
  end

  def generate_types_sql
    SQL.to_sql(generate_types)
  end

  def generate(meta)
    (generate_types + generate_tables(meta))
  end

  def generate_types
    generate_enums +
      base_types +
      generate_complex_types
  end

  def generate_tables(meta)
    generate_table(meta) + child_tables(meta).map do |ref|
      generate_tables(ref)
    end.flatten
  end

  private

  def table_name(meta)
    SCHEMA + '.' + attribute_name((meta[:path] || meta[:name] || '???').pluralize)
  end

  def generate_table(meta)
    table_only_types(meta)<< {
      sql: :table,
      name: table_name(meta),
      columns: generate_attributes(meta[:name],meta)
    }
  end

  def table_only_types(meta)
    meta[:attrs].values.map do |tp|
      next if tp[:collection]
      next unless [:polimorphic, :nested_type].include?(tp[:kind])
      name = attribute_name(tp[:path])
      {
        sql: :type,
        name: name,
        columns: case tp[:kind]
                   when :polimorphic
                     polimorphic_type_columns(tp)
                   when :nested_type
                     generate_attributes(tp[:name], tp)
                   end
      }
    end.compact
  end

  def polimorphic_type_columns(tp)
    { 'type' => { sql: :col, name: 'type', type: 'varchar' },
      'value' => { sql: :col, name: 'value', type: 'varchar' } }
    .tap do |res|
      tp[:type].each do |t|
        pt = primitive_type(t)
        name = "#{pt}_value"
        res[name] = {sql: :col, name: name, type: pt }
      end
    end
  end

  def child_tables(meta)
    meta[:attrs].values.select do |m|
      [:complex_type, :nested_type].include?(m[:kind]) && m[:collection]
    end
  end

  def columns(meta)
    meta[:attrs].values.select do |m|
      [:primitive, :enum].include?(m[:kind]) || ! m[:collection]
    end
  end

  def with_schema(x)
    "#{SCHEMA}.#{x}"
  end

  def column_type(col)
    case col[:kind]
    when :primitive
      primitive_type(col[:type])
    when :complex_type
      with_schema(attribute_name(col[:type]))
    when :polimorphic
      attribute_name(col[:path])
    when :nested_type
      attribute_name(col[:path])
    when :resource_ref
      'uuid'
    when :enum
      with_schema(col[:type])
    when :polimorphic
      col[:kind]
    else
      raise col.inspect
    end
  end

  def type_name(name)
    "#{SCHEMA}.#{name.gsub('.','_').underscore}"
  end

  def generate_enums
    Dt.types.map do |name, enum|
      next unless enum[:kind] == :enum
      { sql: :enum, name: type_name(name), options: enum[:options] }
    end.compact
  end

  def generate_attribute(col_name, col)
    {
      name: attribute_name(col_name),
      type: column_type(col),
      array: col[:collection]
    }
  end

  def generate_attributes(name, tp)
    columns(tp).each_with_object(ActiveSupport::OrderedHash.new) do |col, acc|
      col_name = col[:name]
      next unless col_name.present?
      next if skip_attribute?(col_name, col)
      acc[col_name] = generate_attribute(col_name, col)
    end
  end

  def attribute_name(name)
    name.to_s
    .gsub('[x]','')
    .gsub('.','_')
    .underscore
  end

  def skip_type?(name)
    return true if ['quantity','resource_reference', 'resource', 'extension'].include?(name.to_s.underscore)
  end

  def skip_attribute?(name, el)
    return true if attribute_name(el[:path]) =~ /_comparator$/
    return true if skip_type?(el[:type])
  end

  def base_types
    [
      {
        sql: :type,
        name: "#{SCHEMA}.resource_reference",
        columns: {
          'reference' => {sql: :col, name: 'reference', type: 'uuid'},
          'display' => {sql: :col, name: 'display', type: 'varchar'}
        }
      },
      {
        sql: :type,
        name: "#{SCHEMA}.quantity",
        columns: {
          'reference'=> {sql: :col, name: 'reference', type: 'fhir.quantity_compararator'},
          'units'=> {sql: :col, name: 'units', type: 'varchar'},
          'system'=> {sql: :col, name: 'system', type: 'varchar'},
          'type'=> {sql: :col, name: 'code', type: 'varchar'},
        }
      }
    ]
  end

  def generate_complex_types
    complex_type_tsorted.map do |name|
      next unless name.present?
      tp = Dt.types[name]
      next unless tp
      next unless tp[:kind] == :complex_type
      next if skip_type?(name)
      {
        sql: :type,
        name: type_name(name),
        columns: generate_attributes(name, tp)
      }
    end.compact
  end

  class THash < Hash
    include TSort
    alias tsort_each_node each_key
    def tsort_each_child(node, &block)
      (self[node] || []).each(&block)
    end
  end

  def complex_type_tsorted
    Dt.types
    .each_with_object(THash.new) do |(name, tp), acc|
      next unless tp[:kind] == :complex_type

      acc[name.underscore] = tp[:attrs]
      .values
      .select {|t| t[:kind] == :complex_type }
      .map{|t| t[:path] }
    end.tsort
  end

  def primitive_type(type)
    {
      "code" => 'varchar',
      "datetime" => 'time',
      "string" => 'varchar',
      "uri" => 'varchar',
      "date_time" => 'time',
      "boolean" => 'boolean',
      "base64_binary" => 'bytea',
      "integer" => 'integer',
      "decimal" => 'decimal',
      "sampled_data_data_type" => 'text',
    }[type] || raise("Unknown type #{type}")
  end

  extend self
end
