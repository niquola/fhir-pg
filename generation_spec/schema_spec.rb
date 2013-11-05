require 'active_support/core_ext'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'generation')
require 'gen'
SCHEMA = 'fhir'

describe Gen::Schema do
  subject { described_class }

  example do
    puts subject.generate(resource)
  end

  it "should generate columns for primitives" do
    sql = subject.generate(
      name: 'Patient',
      kind: :resource,
      attributes: [
        { name: 'prim', kind: :primitive, type: 'varchar' },
        { name: 'prims', kind: :primitive, type: 'varchar', collection: true }]
    )

    ['prim varchar', 'prims varchar[]'].each do |str|
      sql.should include(str)
    end
  end

  it "should generate type for neste single type" do
    sql = subject.generate(
      name: 'Patient',
      kind: :resource,
      attributes: [
        { name: 'contact', kind: :nested_type,
          attributes: [
            { name: 'email', kind: :primitive, type: 'varchar' }]
      }]
    )
    puts sql
  end

  def resource
    {
      name: 'Patient',
      kind: :resource,
      attributes: [
        { name: 'bithDate', kind: :primitive, type: 'time' },
        { name: 'bithDate', kind: :primitive, type: 'time', collection: true },
        { name: 'Patient.name', kind: :complex_type, collection: true,
          attributes: [
            { name: 'use', kind: :primitive, type: 'varchar' },
            { name: 'family', kind: :primitive, type: 'varchar', collection: true },
            { name: 'given', kind: :primitive, type: 'varchar', collection: true },]},
        { name: 'Patient.contacts', kind: :nested_type, collection: true,
          attributes: []}
      ]
    }
  end
end
