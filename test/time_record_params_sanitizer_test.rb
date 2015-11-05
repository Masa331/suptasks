require_relative "test_helper"
require_relative "../lib/time_record_params_sanitizer"

class TimeRecordParamsSanitizerTest < Minitest::Test
  def test_permittes_only_selected_params
    params = { 'task_id' => '46',
               'description' => 'ahoj',
               'duration' => '10',
               'started_at' => '16.10.2015',
               'unpermitted' => 'blah' }

    sanitizer = TimeRecordParamsSanitizer.new(params)

    assert_equal({ 'task_id' => '46',
                   'description' => 'ahoj',
                   'duration' => '10',
                   'started_at' => '16.10.2015' }, sanitizer.call)
  end
end
