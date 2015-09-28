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

  def grouped_by_created_at
    uniques = map(&:created_at).uniq
    uniques = map { |time_record| time_record.created_at.to_date }.uniq

    groups = []
    uniques.each do |created_at|
      same = select { |record| record.created_at.to_date == created_at.to_date }

      groups << self.class.new(same)
    end

    groups
  end

  def total_duration
    TimeDuration.new(inject(0) { |sum, record| sum + record.duration })
  end
end
