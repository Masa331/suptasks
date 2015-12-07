class Tag < Sequel::Model(TASK_DB[:tags])
  many_to_one :task
end
