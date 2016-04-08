
module Cargobull
  module Dispatch
    METHOD_MAP = {
      "GET" => :read,
      "POST" => :create,
      "PATCH" => :update,
      "PUT" => :update,
      "DELETE" => :delete
    }

    def self.translate_method_call(env, method)
      METHOD_MAP[method.to_s] ||
        [405, { "Content-Type" => env[:ctype] }, env[:e405] ]
    end

    def self.translate_action_call(env, action)
      Service.dispatch_to(action) ||
        [404, { "Content-Type" => env[:ctype] }, env[:e404] ]
    end

    def self.call(env, method, action, *params)
      klass = translate_action_call(env, action)
      return klass if klass.is_a?(Array) # break on error
      klass = klass.constantize

      method = translate_method_call(env, method)
      return method if method.is_a?(Array) # break on error

      blk = env[:transform_in]
      params = Array[blk.call(*params)] if blk

      obj = klass.is_a?(Class) ? klass.new : klass

      return obj.respond_to?(method) ?
        transform(env, obj.send(method, *params)) :
        [404, { "Content-Type" => env[:ctype] }, env[:e404]]
    end

    def self.transform(env, data)
      blk = env[:transform_out]
      data = blk.call(*data) if blk
      return data.is_a?(Array) && data.count == 3 ? data :
        [200, { "Content-Type" => env[:ctype] }, data]
    end
  end
end
