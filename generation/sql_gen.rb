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
        [%Q["#{col[:name]}"], "#{col[:type]}#{arr}", keys_sql(col)].compact.join(' ')
      end.join(",\n")
    end

    def keys_sql(col)
      case col[:sql]
      when :ref
        "references #{col[:parent_table]}(id)"
      when :pk
        'primary key'
      end
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
    (generate_types + generate_tables(meta).flatten)
  end

  def generate_types
    generate_enums # + base_types + generate_complex_types
  end

  def generate_tables(meta)
    [generate_table(meta)] + collect_meta_for_tables_recur(meta, []).map do |m|
      generate_table(m)
    end
  end

  private

  def table_name(meta)
    SCHEMA + '.' + attribute_name((meta[:path] || meta[:name] || '???').pluralize)
  end

  def generate_table(meta)
    {
      sql: :table,
      name: table_name(meta),
      collection: meta[:collection],
      columns: primary_key(meta)
      .merge(aggregate_key(meta))
      .merge(parent_key(meta))
      .merge(generate_attributes(meta[:name],meta))
    }
  end

  def primary_key(meta)
    { 'id' => {sql: :pk, name: 'id', type: 'uuid'}}
  end

  def parent_key(meta)
    pth = meta[:path].split('.')
    return {} if pth.size < 2
    parent_table = pth[0..-2].join('_').underscore.pluralize
    name = "#{parent_table.singularize}_id"
    { name => {sql: :ref, name: name, type: 'uuid', parent_table: SCHEMA + '.' + parent_table}}
  end

  def aggregate_key(meta)
    pth = meta[:path].split('.')
    return {} if pth.size == 1
    name = "#{pth.first.singularize}_id"
    { name => {sql: :ref, name: name, type: 'uuid', parent_table: SCHEMA + '.' + pth.first.underscore.pluralize}}
  end

  def compound_type?(tp)
    [:polimorphic, :nested_type, :complex_type].include?(tp[:kind])
  end

  def collect_meta_for_tables_recur(meta, acc)
    (meta[:attrs] || {}).each do |name, m|
      next unless compound_type?(m)
      acc<< m
      collect_meta_for_tables_recur(m, acc)
    end
    acc
  end

  def columns(meta)
    (meta[:attrs]  || {}).values.select do |m|
      ! compound_type?(m)
      #[:primitive, :enum].include?(m[:kind]) || ! m[:collection]
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
      with_schema(attribute_name(col[:path]))
    when :nested_type
      with_schema(attribute_name(col[:path]))
    when :resource_ref
      'uuid'
    when :enum
      with_schema(col[:type])
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

  def primitive_type(type)
    {
      "code" => 'varchar',
      "datetime" => 'timestamp',
      "string" => 'varchar',
      "uri" => 'varchar',
      "date_time" => 'timestamp',
      "boolean" => 'boolean',
      "base64_binary" => 'bytea',
      "integer" => 'integer',
      "decimal" => 'decimal',
      "sampled_data_data_type" => 'text',
    }[type] || raise("Unknown type #{type}")
  end

  extend self
end
