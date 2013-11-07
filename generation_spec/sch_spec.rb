require_relative 'gen_spec_helper'
require 'sch'
require 'sql_gen'
require 'sequel'

DB = Sequel.postgres('test', user: 'nicola')
SCHEMA = 'fhir'

describe Gen do
  include described_class

  def sg
    SqlGen
  end

  example do
    struct = Sch.load_profile('pt')

    meta =  Sch.meta(struct)

    meta[:table].should == 'patients'
    # puts meta.to_yaml

    meta[:columns].should_not be_empty
    puts meta.to_yaml

    bd_col = meta[:columns][:birth_date]
    bd_col.should be_present
    bd_col[:kind].should == :primitive
    bd_col[:collection].should be_false

    #todo may be this should go to embeds
    ms_col = meta[:columns][:marital_status]
    ms_col[:kind].should == :complex_type
    ms_col[:type].should == 'CodeableConcept'

    meta[:referenced_by].should_not be_empty
    cnt =  meta[:referenced_by][:contact]
    cnt.should_not be_nil
    cnt[:collection].should be_true
    cnt[:kind].should == :nested_type

    cn = cnt[:columns][:name]
    cn[:type].should == 'HumanName'
    cn[:path].should == 'Patient.contact.name'
    cn[:columns][:period][:path].should == 'Patient.contact.name.period'
    meta[:referenced_by][:address][:columns][:city][:path].should == 'Patient.address.city'
  end

  example do
    struct = Sch.load_profile('pt')
    meta =  Sch.meta(struct)
    sql =  sg.generate_sql(meta)
    fwrite('sch', wrap_sql(sql))
    DB.execute(sql)
  end

  def fwrite(file_name, content)
    open(File.dirname(__FILE__) + "/#{file_name}.sql", 'w')do |f|
      f<< content
    end
  end

  def wrap_sql(content)
    ["-- db:test",
     "--{{{",
    content,
    "--}}}"
    ].join("\n")
  end


  example do
    # puts generate_types.to_yaml
    sql = ''
    sql<< "drop schema if exists fhir cascade;\n"
    sql<< "create schema fhir;\n"
    sql<< sg.generate_enums
    sql<< sg.base_types
    sql<< sg.generate_complex_types
    fwrite('types', wrap_sql(sql))
    DB.execute sql
  end
end
