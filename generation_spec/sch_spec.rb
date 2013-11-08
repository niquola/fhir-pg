require_relative 'gen_spec_helper'

describe Gen do
  include SpecHelpers
  include described_class

  def sg
    SqlGen
  end

  example do
    struct = Sch.load_profile('pt')

    meta =  Sch.meta(struct)
    debug_file('meta.yaml', meta.to_yaml)

    meta[:name].should == 'patient'
    meta[:path].should == 'patient'
    meta[:attrs].should_not be_empty

    bd_col = meta[:attrs][:birth_date]
    bd_col.should be_present
    bd_col[:kind].should == :primitive
    bd_col[:collection].should be_false

    #todo may be this should go to embeds
    ms_col = meta[:attrs][:marital_status]
    ms_col[:kind].should == :complex_type
    ms_col[:type].should == 'codeable_concept'
    cs =  ms_col[:attrs][:coding][:attrs][:system]
    cs[:path].should == 'patient.marital_status.coding.system'
    cs[:kind].should == :primitive

    cnt =  meta[:attrs][:contact]
    cnt.should_not be_nil
    cnt[:collection].should be_true
    cnt[:kind].should == :nested_type

    cn = cnt[:attrs][:name]
    cn[:kind].should == :complex_type
    cn[:type].should == 'human_name'
    cn[:path].should == 'patient.contact.name'
    cn[:attrs][:period][:path].should == 'patient.contact.name.period'
    meta[:attrs][:address][:attrs][:city][:path].should == 'patient.address.city'


    name = meta[:attrs][:name]
    name[:attrs][:family].should_not be_nil
  end

  example do
    struct = Sch.load_profile('pt')
    meta =  Sch.meta(struct)
    sql = ''
    sql<< "drop schema if exists fhir cascade;\n"
    sql<< "create schema fhir;\n"
    sql<<  sg.generate_sql(meta)
    debug_file('schema.sql', wrap_sql(sql))
    DB.execute(sql)
  end

  example do
    struct = Sch.load_profile('pt')
    meta =  Sch.meta(struct)
    objs =  sg.generate(meta)
    debug_file('schema.yaml', objs.to_yaml)
    idx = objs
    .each_with_object({}) do |t, a|
      a[t[:name]] = t
    end

    pd = idx.fetch('patient_deceased')
    pd[:sql].should == :type
    pd[:columns]['type'].should_not be_nil
    bv = pd[:columns]['boolean_value']
    bv.should_not be_nil

    pd = idx.fetch('patient_animal')
    pd[:sql].should == :type
    pd[:columns]['species'].should_not be_nil

    pt = idx['fhir.patients']
    pt[:columns].should_not be_empty
    bd = pt[:columns]['birth_date']
    bd.should_not be_nil
    bd[:type].should == 'time'

    [
      'patients',
      'patient_names',
      #'patient_matrial_status_codings'
    ].each do |t|
      idx['fhir.' + t].should_not be_nil
    end
  end
end
