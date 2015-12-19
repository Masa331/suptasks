require_relative 'test_helper'

class TaskParamsSanitizerTest < Minitest::Test
  def test_permittes_only_selected_params
    params = { 'description' => 'desc',
               'time_cost' => '20',
               'tags' => 'tag1, tag2',
               'unpermitted' => 'blah' }

    sanitizer = TaskParamsSanitizer.new(params)

    assert_equal({ 'description' => 'desc',
                   'time_cost' => '20',
                   'tags' => 'tag1, tag2' }, sanitizer.call)
  end
end
