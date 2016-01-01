class Tag < Sequel::Model(TASK_DB[:tags])
  many_to_one :task

  def after_create
    touch_associations
    super
  end
end

Tag.plugin :touch, associations: [:task]
