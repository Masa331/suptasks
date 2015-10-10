require_relative "test_helper"

require_relative "../models/time_records"
require_relative "../models/time_record"

class TimeRecordsTest < Minitest::Test
  def test_time_records_delegate
    record1 = TimeRecord.new(task_id: 1)
    record2 = TimeRecord.new(task_id: 1)

    time_records = TimeRecords.new([record1, record2])

    assert_equal 2, time_records.count
  end

  def test_total_duration
    record1 = TimeRecord.new(duration: 10)
    record2 = TimeRecord.new(duration: 10)

    time_records = TimeRecords.new([record1, record2])

    assert_instance_of TimeDuration, time_records.total_duration
    assert_equal 20, time_records.total_duration.duration
  end

  def test_grouping_by_task
    record1 = TimeRecord.new(task_id: 1)
    record2 = TimeRecord.new(task_id: 1)
    record3 = TimeRecord.new(task_id: 2)

    time_records = TimeRecords.new([record1, record2, record3])

    grouped = time_records.grouped_by_task

    assert_equal 2, grouped.size

    group1 = grouped.first
    assert_instance_of TimeRecords, group1
    assert_includes group1, record1
    assert_includes group1, record2

    group2 = grouped.last
    assert_instance_of TimeRecords, group2
    assert_includes group2, record3
  end
end
