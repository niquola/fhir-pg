require 'rubygems'
require 'sequel'
require 'json'

db = Sequel.postgres('fhir', user: 'nicola')

# db.drop_table :patients
# db.create_table! :patients do
#   primary_key :id
#   column :content, 'json'
# end
pt = db[:patients]

json = File.read('pt.json').chomp
pt.insert(content: json)




