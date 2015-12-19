require_relative 'test_helper'

class TimeRecordsPagerTest < Minitest::Test
  def test_at_least_one_page_is_returned
    paged = TimeRecordsPager.by_number_of_days(TimeRecord.select_all, 1)

    assert_instance_of Array, paged
    assert_instance_of TimeRecords, paged.first
  end
end
