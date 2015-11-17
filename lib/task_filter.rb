require 'sequel'

class TaskFilter
  class DescriptionFilter
    def initialize(description, dataset)
      @description = description
      @dataset = dataset
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
    def initialize(status, dataset)
      @status = status
      @dataset = dataset
    end

    def call
      if @status.nil?
        @dataset
      else
        @dataset.where(completed: @status)
      end
    end
  end

  class TagsFilter
    def initialize(tags, dataset)
      @tags = tags
      @dataset = dataset
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

  def initialize(params = {}, dataset)
    @description = params.fetch('description', nil)
    @status = parse_status(params.fetch('status', '0'))
    @tags = parse_tags(params.fetch('tags', ''))
    @dataset = dataset
  end

  def call
    filtered = DescriptionFilter.new(description, dataset).call
    filtered = StatusFilter.new(status, filtered).call
    TagsFilter.new(tags, filtered).call
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
