require_relative 'time_duration'

class TimeRecords < SimpleDelegator
  def initialize(time_records)
    super
  end

  def grouped_by_task
    uniques = map(&:task_id).uniq

    groups = []
    uniques.each do |task_id|
      same = select { |record| record.task_id == task_id }

      groups << self.class.new(same)
    end

    groups
  end

  def total_duration
    TimeDuration.new(inject(0) { |sum, record| sum + record.duration })
  end
end
