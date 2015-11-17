require 'sequel'

DB = Sequel.sqlite
Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')

require_relative "test_helper"
require_relative "../lib/task"
require_relative "../lib/tag"

class TaskTest < Minitest::Test
  def test_completed_returns_true_or_false_based_on_specific_tag_presence
    completed_task = Task.create(description: 'Some desc')
    Tag.create(name: 'completed', task_id: completed_task.id)
    uncomplete_task = Task.create(description: 'Some desc')

    assert completed_task.completed?
    refute uncomplete_task.completed?
  end

  def test_update_tags_on_task
    task = Task.create(description: 'Some task')
    Tag.create(name: 'tag1', task_id: task.id)
    Tag.create(name: 'tag2', task_id: task.id)

    task.update_tags('tag1, tag3')

    assert_equal 'tag1, tag3', task.tag_names
  end

  def test_update_tags_in_database
    task = Task.create(description: 'Some task')
    Tag.create(name: 'tag1', task_id: task.id)
    Tag.create(name: 'tag2', task_id: task.id)

    task.update_tags('tag1, tag3')

    assert_instance_of Tag, Tag.find(name: 'tag1', task_id: task.id)
    assert_instance_of Tag, Tag.find(name: 'tag3', task_id: task.id)

    assert_nil Tag.find(name: 'tag2', task_id: task.id)
  end
end
