require 'cargobull'

module Cargobull
  module TestHelper
    [:get, :post, :put, :patch, :delete].each do |m|
      define_method(m) do |env, action, *args|
        Cargobull::Dispatch.call(env, m.to_s.upcase, action, *args)
      end
    end
  end
end

include Cargobull::TestHelper
