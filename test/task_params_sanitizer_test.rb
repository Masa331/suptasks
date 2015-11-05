require_relative "test_helper"
require_relative "../lib/task_params_sanitizer"

class TaskParamsSanitizerTest < Minitest::Test
  def test_permittes_only_selected_params
    params = { 'description' => 'desc',
               'time_cost' => '20',
               'completed' => 'true',
               'tags' => 'tag1, tag2',
               'unpermitted' => 'blah' }

    sanitizer = TaskParamsSanitizer.new(params)

    assert_equal({ 'description' => 'desc',
                   'time_cost' => '20',
                   'completed' => 'true',
                   'tags' => 'tag1, tag2' }, sanitizer.call)
  end
end
