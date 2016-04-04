
module Cargobull
  module Service
    @dispatch = []

    def self.dispatch
      return @dispatch
    end

    def self.dispatch_to(action)
      return dispatch.detect do |klass_name|
        next klass_name.underscore == action.to_s
      end
    end

    def self.register(klass_name)
      @dispatch << klass_name unless @dispatch.include?(klass_name)
    end

    def self.included(base)
      register(base.name)
    end
  end
end
