require 'rubygems'
require 'sequel'
require 'json'
require 'active_support/core_ext'
require 'uuid'
require 'json'

DB = Sequel.postgres('test', user: 'nicola')
DB.extension(:pg_array, :pg_row)
Sequel.extension :pg_array_ops, :pg_row_ops
DB.register_row_type(:codableconcept)
DB.register_row_type(:humanname)
Pt = DB[:patients]

def arr(*args)
  Sequel.pg_array(args)
end

def rt(name, attrs)
  DB.row_type(name, attrs)
end

def create_pt
  pid = UUID.generate

  Pt.insert(
    id: pid,
    bith_date: Time.now - 30.years,
    marital_status: rt(:codableconcept, text: 'Maried')
  )

  pt_i = DB[:patient_identifiers]

  pt_i.insert(
    patient_id: pid,
    use: 'common',
    label: 'medical record number',
    value: '12-13-14'
  )

  pt_i.insert(
    patient_id: pid,
    use: 'common',
    label: 'ssn',
    value: '12131415'
  )

  pt_n = DB[:patient_names]
  pt_n.insert(
    patient_id: pid,
    use: 'common',
    family: arr('Ukupnik','Nizovskiy'),
    given: arr('Lisa')
  )
  pt_n.insert(
    patient_id: pid,
    use: 'alias',
    given: arr('Lisok')
  )

  pt_c = DB[:patient_contacts]
  pt_c.insert(
    patient_id: pid,
    name: rt(:humanname,
             family: arr('Ukupnik','Nizovskiy'),
             given: arr('Vasiliy')
            )
  )
  pt_c_r = DB[:patient_contact_relationships]
  rid = pt_c_r.insert(
    patient_id: pid,
    text: 'Father'
  )
  pt_c_r_c = DB[:patient_contact_relationship_codings]
  pt_c_r_c.insert(
    patient_id: pid,
    relationship_id: rid,
    system: 'fhir',
    code: 'm',
    display: 'mother'
  )
end

# create_pt
#
Meta = {
  table: 'patients',
  has_many: {
    names: {
      table: 'patient_names'
    },
    identifiers: {
      table: 'patient_identifiers'
    },
    contacts: {
      table: 'patient_contacts',
      has_many: {
        relationships: {
          table: 'patient_contact_relationships',
          has_many: {
            codings: {
              table: 'patient_contact_relationship_codings'
            }
          }
        }
      }
    }
  }
}

def next_table_name
  @counter ||= 0
  @counter += 1
  "t#{@counter}"
end

def ident(str, deep)
  str.split("\n").map{|l| "#{' '*4*deep}#{l}"}.join("\n")
end

def build_sql(obj, deep = 0)
  t = next_table_name

  sel = if obj[:has_many]
    obj[:has_many].map do |col, o|
      "( #{build_sql(o, deep + 1)} ) as #{col}"
    end.join(",\n")
  end

  <<-SQL
select array_to_json(array_agg(row_to_json(#{t}, true)), true) from
(
  select #{t}.*#{sel.present? ? ",\n  #{ident(sel, deep + 1)}" : ''}
  from #{obj[:table]} #{t}
) #{t}
  SQL
end

create_pt

def select
  sql = build_sql(Meta)
  # puts sql
  puts JSON.parse(DB[sql].all.first.values.first).to_yaml
end

select
