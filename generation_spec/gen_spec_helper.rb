$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'generation')
require 'active_support/core_ext'
require 'gen'
require 'dt'
require 'sch'
require 'sql_gen'
require 'sequel'

SCHEMA = 'fhir'
DB = Sequel.postgres('test', user: 'nicola')

module SpecHelpers
  def debug_file(file_name, content)
    file = File.dirname(__FILE__) + "/tmp/#{file_name}"
    puts "fwrite to #{file}"
    open(file, 'w') { |f| f<< content }
  end

  def wrap_sql(content)
    ["-- db:test",
     "--{{{",
    content,
    "--}}}"
    ].join("\n")
  end
end
