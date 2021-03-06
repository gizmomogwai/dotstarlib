require 'dotstarlib/dim_filter'

module DotStarLib
  class PulseFilter < DimFilter
    def initialize
      @dim_filter = DimFilter.new
      @state = 0
      @direction = 1
    end
    def process(channels)
      new_state = @state + @speed * @direction
      if new_state > 255 || new_state < 0
        @direction = -@direction
        new_state = @state + @speed * @direction
      end
      @state = new_state
      return @dim_filter.set({factor: @state}).process(channels)
    end

    def set(params)
      @speed = params[:speed]
      return self
    end
    register("Pulse", [:speed])
  end
end
