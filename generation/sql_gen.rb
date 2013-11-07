require 'tsort'
module SqlGen
  def column_type(col)
    case col[:kind]
    when :primitive
      primitive_type(col[:type])
    when :complex_type
      attribute_name(col[:type])
    when :polimorphic
      attribute_name(col[:path])
    when :nested_type
      attribute_name(col[:path])
    when :enum
      col[:type]
    end
  end

  def type_name(name)
    SCHEMA + '.' + name.gsub('.','_').underscore
  end

  def generate_enums
    Dt.enums.map do |name, enum|
      <<-SQL
CREATE TYPE #{type_name(name)} AS ENUM (#{enum[:options].map{|o| "'#{o}'"}.join(',')});
      SQL
    end.join("\n")
  end

  def generate_attribute(col_name, col)
    name = attribute_name(col_name)
    if [:enum, :complex_type].include?(col[:kind])
      %Q["#{name}" fhir.#{column_type(col)}]
    else
      %Q["#{name}" #{column_type(col)}]
    end
  end

  def generate_attributes(name, tp)
    tp[:columns].map do |col_name, col|
      next unless col_name
      next if skip_attribute?(col_name, col)
      generate_attribute(col_name, col)
    end.compact.join(",\n")
  end

  def attribute_name(name)
    name.to_s
    .gsub('[x]','')
    .gsub('.','_')
    .underscore
  end

  def skip_type?(name, tp)
    return true if ['quantity','resource_reference', 'resource', 'extension'].include?(name.to_s.underscore)
  end

  def skip_attribute?(name, el)
    return true if attribute_name(el[:path]) =~ /_comparator$/
  end

  def base_types
    <<-SQL
create type #{SCHEMA}.resource_reference AS (
  reference uuid,
  display varchar
);

CREATE TYPE #{SCHEMA}.quantity AS (
  "value" varchar,
  "comparator" fhir.quantity_compararator,
  "units" varchar,
  "system" varchar,
  "code" varchar
);
    SQL
  end

  def generate_complex_types
    cts = Dt.complex_types
    puts complex_type_tsorted
    complex_type_tsorted.map do |name|
      tp = cts[name]
      next unless tp
      next if skip_type?(name, tp)
      next unless tp[:kind] == :complex_type
      next unless name.present?

      %Q[CREATE TYPE #{type_name(name)} AS (\n#{generate_attributes(name, tp)}\n);]
    end.compact.join("\n")
  end

  class THash < Hash
    include TSort
    alias tsort_each_node each_key
    def tsort_each_child(node, &block)
      (self[node] || []).each(&block)
    end
  end

  def complex_type_tsorted
    Dt.complex_types
    .each_with_object(THash.new) do |(name, tp), acc|
      acc[name.underscore] = tp[:columns]
      .values
      .select {|t| t[:kind] == :complex_type}
      .map{|t| t[:path].underscore}
    end.tsort
  end

  def primitive_type(type)
    {
      "code" => 'varchar',
      "datetime" => 'time',
      "string" => 'varchar',
      "uri" => 'varchar'
    }[type] || 'varchar'
  end

  def generate_sql(meta)
    sql = <<-SQL
create table #{attribute_name(meta[:path] || meta[:name] || 'ups').pluralize} (
id uuid PRIMARY KEY default uuid_generate_v4(),
    #{generate_attributes(meta[:name],meta)}
);
    SQL

    sql + (meta[:referenced_by] || {}).map do |name, ref|
      generate_sql(ref)
    end.join("\n")
  end
  extend self
end
