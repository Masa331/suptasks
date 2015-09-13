require_relative '../database/database.rb'

class Task < Sequel::Model
  one_to_many :time_records

  def self.uncompleted
    where(completed: 0).all
  end

  def id_with_short_desc
    "#{id} - #{description[0..10]}..."
  end

  def tags
    []
  end
end
