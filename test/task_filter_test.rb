require_relative "test_helper"
require_relative "../lib/task_filter"

class TaskFilterTest < Minitest::Test
  def test_to_s
    filter = TaskFilter.new('description' => 'hello')
    assert_equal "Showing tasks with 'hello' in description.", filter.to_s

    filter = TaskFilter.new('description' => '')
    assert_equal "Showing uncomplete tasks.", filter.to_s
  end
end
