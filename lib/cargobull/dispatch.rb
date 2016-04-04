
module Cargobull
  module Dispatch
    def self.translate_method_call(cargoenv, method)
      return case method.to_s.downcase
      when "get"
        :read
      when "post"
        :create
      when "patch", "put"
        :update
      when "delete"
        :delete
      else
        [405, { "Content-Type" => cargoenv[:ctype] }, cargoenv[:e405] ]
      end
    end

    def self.translate_action_call(cargoenv, action)
      Service.dispatch_to(action) ||
        [404, { "Content-Type" => cargoenv[:ctype] }, cargoenv[:e404] ]
    end

    def self.call(cargoenv, method, action, params)
      klass = translate_action_call(cargoenv, action)
      return klass if klass.is_a?(Array) # break on error
      klass = klass.constantize

      method = translate_method_call(cargoenv, method)
      return method if method.is_a?(Array) # break on error

      blk = cargoenv[:transform_in]
      params = blk.call(params) if blk

      obj = klass.is_a?(Class) ? klass.new : klass

      return obj.respond_to?(method) ?
        transform(cargoenv, obj.send(method, params)) :
        [404, { "Content-Type" => cargoenv[:ctype] }, cargoenv[:e404] ]
    end

    def self.transform(cargoenv, data)
      blk = cargoenv[:transform_out]
      return blk ? blk.call(data) :
        [200, { "Content-Type" => cargoenv[:ctype] }, data]
    end
  end
end
