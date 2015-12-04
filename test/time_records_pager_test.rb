require_relative "database_helper"
require_relative "test_helper"
require_relative "../lib/time_records_pager"
require_relative "../lib/time_record"
require_relative "../lib/time_records"

class TimeRecordsPagerTest < Minitest::Test
  def test_at_least_one_page_is_returned
    paged = TimeRecordsPager.by_number_of_days(TimeRecord.select_all, 1)

    assert_instance_of Array, paged
    assert_instance_of TimeRecords, paged.first
  end
end
