class TimeRecord < Sequel::Model
  many_to_one :task
end
