require 'dotstarlib/generator'

module DotStarLib
  # sums up results from filters
  # a filter produces several channels
  class SumGenerator < Generator
    def initialize(generators)
      @generators = generators
    end
    
    def process(channel)
      generator_results = @generators.map{ |g|
        g.process(channel)
      }

      size = generator_results.first.size
      values = (0...size).map {|i|
        generator_results.inject(Value.new(0, 0, 0)) {|memo, v|
          memo.add(v.values[i])
        }
      }
      return Channel.new(values)
    end
  end
end

