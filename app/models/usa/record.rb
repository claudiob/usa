# What every record this gem holds descends from, so a host says in one line how they connect.
class USA::Record < ActiveRecord::Base
  self.abstract_class = true

  # Read rather than stored, so an initializer setting it is in time whenever a model loads.
  # @return [String] what this gem's tables are named with.
  def self.table_name_prefix = USA.table_name_prefix
end

ActiveSupport.run_load_hooks :usa_record, USA::Record
