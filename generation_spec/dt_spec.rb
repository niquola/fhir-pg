require_relative 'gen_spec_helper'

describe Dt do
  include SpecHelpers
  subject { described_class }

  def sg
    SqlGen
  end

  example do
    subject.types.should_not be_empty
    subject.types['date'].should_not be_nil

    debug_file('types.yaml', subject.types.to_yaml)

    au = subject.types['address_use']
    au[:kind].should == :enum
    au.should_not be_nil
    au[:options].should include('work')

    ad = subject.types['address']
    ad[:kind] = :complex_type
    ad[:attrs].should_not be_empty
    ad[:attrs][:use].should_not be_nil
    ad[:attrs][:period][:attrs][:start].should_not be_nil

    cc = subject.types['codeable_concept']
    cc[:kind].should == :complex_type
    cc[:attrs][:text].should_not be_nil

    hn = subject.types['human_name']
    fm = hn[:attrs][:family]
    fm[:collection].should be_true
    fm[:kind].should == :primitive
  end

  example do
    # puts generate_types.to_yaml
    sql = ''
    sql<< "drop schema if exists fhir cascade;\n"
    sql<< "create schema fhir;\n"
    sql<< sg.generate_types_sql
    debug_file('types.sql', wrap_sql(sql))
    DB.execute sql
  end
end
