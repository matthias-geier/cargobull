
module Cargobull
  module Service
    @dispatch = []

    def self.dispatch
      return @dispatch
    end

    def self.dispatch_to(action)
      return self.dispatch.detect do |klass|
        next klass.name.underscore == action.to_s
      end
    end

    def self.register(klass)
      @dispatch << klass
    end

    def self.included(base)
      self.register base
    end

    def initialize(*args)
      @params = args.shift
    end
  end
end
