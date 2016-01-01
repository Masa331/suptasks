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

  attr_accessor :description, :tags, :dataset

  DEFAULT_TAGS = '-hide, -completed'

  def initialize(dataset, params = {})
    @dataset = dataset
    @description = params['description']
    @tags = parse_tags(params.fetch('tags', DEFAULT_TAGS))
  end

  def call
    filtered = FilterByDescription.new(dataset, description).call

    FilterByTags.new(filtered, tags).call
  end

  private

  def parse_tags(tags)
    tags.split(',').map(&:strip)
  end
end
