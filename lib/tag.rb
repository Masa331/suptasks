require_relative 'database_manager'

class Tag < Sequel::Model
  many_to_one :task
end
