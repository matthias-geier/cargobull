
module Cargobull
  module Dispatch
    def self.translate_method_call(method)
      return case method.to_s.downcase
      when "get", "post"
        :read
      when "put"
        :create
      when "patch"
        :update
      when "delete"
        :delete
      else
        raise RuntimeError.new("Unsupported method: #{method}")
      end
    end

    def self.translate_action_call(action)
      return Service.dispatch_to(action)
    end

    def self.call(method, action, *args)
      klass = self.translate_action_call(action)
      if klass.nil?
        raise RuntimeError.new("Unsupported action: #{action}")
      end

      obj = klass.new(*args)
      method = self.translate_method_call(method)
      unless obj.respond_to?(method)
        raise RuntimeError.new("#{action} does not respond to #{method}")
      end

      return self.transform(obj.send(method))
    end

    def self.transform(data)
      return data
    end
  end
end
