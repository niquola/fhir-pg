module Gen

  # primitive => column
  # primitive array => column []
  # nested => custom type + column
  # nested array => table
  module Schema
    def generate(type, parent = nil, root = nil)
      [
        nested_types(type, parent, root),
        table(type, parent, root),
        children_tables(type, parent, root || type)
      ].join("\n")
    end

    def table(type, parent = nil, root = nil)
      <<-SQL
create #{table_name(type)} (
  id uuid PRIMARY KEY default uuid_generate_v4(),
      #{foreign_keys(type, parent, root)}
      #{columns(type)}
);
      SQL
    end

    def nested_types(type, parent, root)
      type[:attributes].select {|a|
        a[:kind] == :nested_type && !a[:collection]
      }.map do |tp|
        <<-SQL
CREATE TYPE #{tp[:name]} (
        #{columns(tp)}
);
        SQL
      end.join("\n")
    end

    def columns(type)
      type[:attributes].map do |attr|
        case attr[:kind]
        when :primitive
          column(type, attr)
        when :nested_type
          "#{attr[:name]} #{attr[:name]}" unless attr[:collection]
        when :complex_type
          "#{attr[:name]} #{attr[:type]}" unless attr[:collection]
        else
          "-- #{attr[:name]} #{attr[:kind]} #{attr[:type]}"
        end
      end.compact.map{|l| indent(l, 2)}
      .join(",\n")
    end

    def table_name(type)
      name = type[:path].gsub('.','_')
      "#{SCHEMA}."<< name.underscore.pluralize
    end

    def foreign_keys(type, parent, root)
      [parent, root]
      .uniq
      .compact.map do |ref|
        "#{table_name(ref).singularize}_id uuid references #{table_name(ref)}(id)"
      end
      .map{|l| indent(l, 2)}
      .join(",\n")
    end

    def indent(str, ind)
      str.split("\n").map{|l| "#{' '*ind}#{l}"}.join("\n")
    end


    def column(type, attr)
      col_type = attr[:type]
      col_name = attr[:name].underscore
      if attr[:collection]
        "#{col_name.pluralize} #{col_type}[]"
      else
        "#{col_name} #{col_type}"
      end
    end

    def children_tables(type, parent, root)
      type[:attributes].map do |attr|
        if [:complex_type, :nested_type].include?(attr[:kind]) && attr[:collection]
          generate(attr, type, root)
        end
      end.join("\n")
    end

    extend self
  end
end
