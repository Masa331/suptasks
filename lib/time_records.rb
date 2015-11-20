require 'delegate'
require_relative 'time_duration'

class TimeRecords < SimpleDelegator
  def initialize(time_records = [])
    super
  end

  def grouped_by_task
    group_by(&:task_id).map { |_, v| TimeRecords.new(v) }
  end

  def grouped_by_started_at
    group_by { |record| record.started_at.to_date }
      .each_with_object({}) { |(k, v), hash| hash[k] = TimeRecords.new(v) }
  end

  def total_duration
    inject(TimeDuration.new) { |sum, record| sum + record.duration }
  end

  def select(&block)
    if __getobj__.is_a? Sequel::SQLite::Dataset
      self.class.new(__getobj__.select(&block))
    else
      super
    end
  end
end
