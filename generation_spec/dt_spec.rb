require 'active_support/core_ext'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'generation')
require 'gen'
require 'dt'
SCHEMA = 'fhir'

describe Dt do
  subject { described_class }

  example do
    subject.primitives.should_not be_empty
    subject.primitives['date'].should_not be_nil
    # puts subject.primitives.keys.sort.to_yaml

    subject.enums.should_not be_empty
    au = subject.enums['address_use']
    au.should_not be_nil
    au[:options].should include('work')


    ad = subject.complex_types['address']
    ad[:kind] = :complex_type
    ad[:columns].should_not be_empty
    ad[:columns][:use].should_not be_nil
    ad[:columns][:period][:columns][:start].should_not be_nil

    cc = subject.complex_types['codeable_concept']
    cc[:columns][:text].should_not be_nil
    # puts cc.to_yaml

    open(File.dirname(__FILE__) + '/types.yaml', 'w') {|f| f<< subject.types.to_yaml }
  end
end
