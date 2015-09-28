class TimeRecordsDecorator < SimpleDelegator
  def initialize(time_records)
    super
  end

  def grouped_by_task(&block)
    uniques = map(&:task_id).uniq

    groups = []
    uniques.each do |task_id|
      same = select { |record| record.task_id == task_id }

      groups << TimeRecordsGrouped.new(same.first.task.id_with_short_desc, same.inject(0) { |sum, record| sum + record.duration })
    end

    groups.each do |group|
      yield group
    end
  end
end
