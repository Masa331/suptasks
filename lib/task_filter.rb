require 'sequel'

class TaskFilter
  class FilterByDescription
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

  class FilterByStatus
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

  class FilterByTags
    def initialize(dataset, tags)
      @dataset = dataset
      @tags = tags
    end

    def call
      searched_tags = @tags.select { |tag| !tag.start_with?('-') }
      unwanted_tags = (@tags - searched_tags).map { |tag| tag[1..-1] }

      filtered = with_tags(@dataset, searched_tags)
      without_tags(filtered, unwanted_tags)
    end

    private

    def with_tags(dataset, tags)
      subqueries = subqueries(tags)

      subqueries(tags).reduce(dataset) { |dataset, subquery| dataset.where(id: subquery) }
    end

    def without_tags(dataset, tags)
      subqueries = subqueries(tags)

      subqueries.reduce(dataset) { |dataset, subquery| dataset.exclude(id: subquery) }
    end

    def subqueries(tags)
      tags.map { |tag| Tag.where(name: tag).select(:task_id) }
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
    filtered = FilterByDescription.new(dataset, description).call
    filtered = FilterByStatus.new(filtered, status).call
    FilterByTags.new(filtered, tags).call
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
