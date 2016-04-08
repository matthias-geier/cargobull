require 'cargobull'

module Cargobull
  module TestHelper
    [:get, :post, :put, :patch, :delete].each do |m|
      define_method(m) do |env, action, *args, &blk|
        r = Cargobull::Dispatch.call(env, m.to_s.upcase, action, *args)
        blk.call(r) if block_given?
        next r
      end
    end
  end
end

include Cargobull::TestHelper
