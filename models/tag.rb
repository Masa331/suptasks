require_relative '../database/database.rb'

class Tag < Sequel::Model
  many_to_one :task
end
