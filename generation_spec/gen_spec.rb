require_relative 'gen_spec_helper'

describe Gen do
  include described_class
  example do
    generate
    # generate('2.7.1')
    # $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
    # require 'health_seven'
    # Dir["#{File.dirname(__FILE__)}/../lib/health_seven/2.7.1/**/*rb"].each do |f|
    #   require f
    # end
  end
end
