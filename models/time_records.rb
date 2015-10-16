require_relative 'time_duration'

class TimeRecords < SimpleDelegator
  def initialize(time_records)
    super
  end

  def grouped_by_task
    uniques = map(&:task_id).uniq

    uniques.map do |task_id|
      same = select { |record| record.task_id == task_id }

      self.class.new(same)
    end
  end

  def grouped_by_created_at
    uniques = map(&:created_at).uniq
    uniques = map { |time_record| time_record.created_at.to_date }.uniq

    uniques.map do |created_at|
      same = select { |record| record.created_at.to_date == created_at.to_date }

      self.class.new(same)
    end
  end

  def total_duration
    TimeDuration.new(inject(0) { |sum, record| sum + record.duration })
  end

  def select(&block)
    if __getobj__.is_a? Sequel::SQLite::Dataset
      self.class.new(__getobj__.select(&block))
    else
      super
    end
  end
end
