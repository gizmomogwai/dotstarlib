require 'dotstarlib/filters'

module DotStarLib
  # sums up results from filters
  # a filter produces several channels
  class SumFilter < Filter
    def initialize(filters)
      @filters = filters
    end
    def process(channel)
      filter_results = @filters.map{ |f|
        f.process(channel)
      }

      size = filter_results.first.size
      values = (0...size).map {|i|
        filter_results.inject(Value.new(0, 0, 0)) {|memo, v|
          memo.add(v.values[i])
        }
      }
      return Channel.new(values)
    end
  end
end

