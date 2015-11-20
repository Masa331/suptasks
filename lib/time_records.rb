require 'delegate'
require_relative 'time_duration'

class TimeRecords < SimpleDelegator
  def initialize(time_records)
    super
  end

  def grouped_by_task
    group_by(&:task_id).map { |_, v| TimeRecords.new(v) }
  end

  def grouped_by_started_at
    group_by { |record| record.started_at.to_date }.map { |_, v| TimeRecords.new(v) }
  end

  def grouped_by_dates_between(start_date, end_date)
    by_starte_at = grouped_by_started_at
    by_date = {}

    (start_date).upto(end_date).each do |date|
      by_date[date] = (by_starte_at.find(-> { TimeRecords.new([]) }) { |group| group.first.started_at.to_date == date })
    end

    by_date
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
