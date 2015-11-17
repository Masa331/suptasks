# TaskParamsSanitizer takes hash of params from html form and return other hash
#   with only params which are permitted for Task. It's similar to Rails permitted params
class TaskParamsSanitizer
  attr_reader :params

  PERMITTED_KEYS = ['description', 'time_cost', 'tags']

  def initialize(params)
    @params = params
  end

  def call
    params.keep_if { |key, _| PERMITTED_KEYS.include? key }
  end
end
