require 'active_support/core_ext'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'generation')
require 'gen'
require 'dt'
require 'sql_gen'
require 'sequel'

SCHEMA = 'fhir'
DB = Sequel.postgres('test', user: 'nicola')

describe Dt do
  subject { described_class }

  def sg
    SqlGen
  end

  example do
    subject.types.should_not be_empty
    subject.types['date'].should_not be_nil

    open(File.dirname(__FILE__) + '/types.yaml', 'w') do
      |f| f<< subject.types.to_yaml
    end

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
    sql<< sg.generate_types
    fwrite('types', wrap_sql(sql))
    DB.execute sql
  end
end
