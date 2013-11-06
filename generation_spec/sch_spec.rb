require_relative 'gen_spec_helper'
require 'sch'

describe Gen do
  include described_class

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
  end
end
