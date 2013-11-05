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
    bd_col = meta[:columns].select {|c| c[:name] == 'birth_date'}.first
    bd_col.should be_present
    bd_col[:kind].should == :primitive
    bd_col[:collection].should be_false

    meta[:referenced_by].should_not be_empty
    cnt =  meta[:referenced_by].find {|r| r[:path] == 'Patient.contact' }
    cnt.should_not be_nil
    cnt[:collection].should be_true
    cnt[:kind].should == :nested_type
    p cnt[:referenced_by]
    # puts cnt.to_yaml

    meta[:embeds].should_not be_empty
    #todo may be this should go to embeds
    ms_col = meta[:embeds].select {|c| c[:name] == 'marital_status'}.first
    ms_col[:kind].should == :complex_type
    ms_col[:type].should == 'CodeableConcept'

    # puts meta[:custom_types].to_yaml
    meta[:custom_types].should_not be_empty
  end
end
