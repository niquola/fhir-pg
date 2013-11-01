require_relative 'gen_spec_helper'

describe Gen do
  include described_class

  # RULES
  #
  # Resource, ValueObject, Type
  #
  # attribute type:
  #   primitive
  #   complex type
  #   value_object
  #   Type Union
  #   resource ref
  #
  #
  # Resourse has one primitive   => column
  # Resourse has many primitive  => column[]
  # Resourse has one (ValueObject || ComplexType)  => (1-1) table || pg_type
  # Resourse has many (ValueObject || ComplexType) => (1-*) table
  # Resourse has one UnionType   => column

  def attribute_type(db, el)
    m = Gen::Meta
    types = m.types(el)
    if types.empty?
      :nested_type
    elsif types.size == 1
      if db.datatypes["#{types.first}-primitive"]
        :primitive
      else
        :complex_type
      end
    else types.size == 1
      :union
    end
  end

  example do
    db = Gen::Db
    m = Gen::Meta
    tm = Gen::TypeMeta
    db.elements.each do |path, el|
      next unless path.start_with?('Patient')
      next if m.technical?(el)
      next unless m.direct_parent?('Patient', el)
      mul = m.attr(el, 'max')
      puts "#{path} #{attribute_type(db, el)} #{mul} #{m.types(el)}"
      # tp_el = db.datatypes["#{m.type(el)}-primitive"]
      # next unless tp_el
      # types = m.types(el)
      # name = (path.split('.') - ['Patient']).first.underscore
    end
  end
end
