require 'sequel'

class TaskFilter
  class DescriptionFilter
    def initialize(dataset, description)
      @dataset = dataset
      @description = description
    end

    def call
      if @description
        @dataset.where(Sequel.ilike(:description, "%#{@description}%"))
      else
        @dataset
      end
    end
  end

  class StatusFilter
    def initialize(dataset, status)
      @dataset = dataset
      @status = status
    end

    def call
      if @status.nil?
        @dataset
      elsif @status
        @dataset.where(id: Tag.where(name: 'completed').select(:task_id))
      else
        @dataset.exclude(id: Tag.where(name: 'completed').select(:task_id))
      end
    end
  end

  class TagsFilter
    def initialize(dataset, tags)
      @dataset = dataset
      @tags = tags
    end

    def call
      subqueries = @tags.map do |tag|
        Tag.where(name: tag).select(:task_id)
      end

      subqueries.each do |subquery|
        @dataset = @dataset.where(id: subquery)
      end

      @dataset
    end
  end

  attr_accessor :description, :status, :tags, :dataset

  def initialize(dataset, params = {})
    @dataset = dataset
    @description = params.fetch('description', nil)
    @status = parse_status(params.fetch('status', '0'))
    @tags = parse_tags(params.fetch('tags', ''))
  end

  def call
    filtered = DescriptionFilter.new(dataset, description).call
    filtered = StatusFilter.new(filtered, status).call
    TagsFilter.new(filtered, tags).call
  end

  private

  def parse_status(status)
    case status
    when '0' then false
    when '1' then true
    end
  end

  def parse_tags(tags)
    tags.split(',').map(&:strip)
  end
end
