module Gen::TypeMeta

  def column_type(el)
    {
      boolean: 'boolean',
      dataTime: 'datetime'
    }[name(el).try(:to_sym)]
  end

  def name(el)
    el[:name]
  end

  extend self
end
