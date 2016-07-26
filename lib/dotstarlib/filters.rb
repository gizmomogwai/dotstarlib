module DotStarLib
  class Filter
    @@filters = {}
    def self.register(name, params)
      @@filters[name] = {clazz: self, params: params}
    end
    def self.filters
      @@filters
    end
    def process(channels)
      raise 'process(channels) not implemented'
    end
    def set(params)
      raise 'set(params) not implemented'
    end
  end
end

