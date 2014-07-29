require 'cargobull'

module Cargobull
  module TestHelper
    def response
      return @response || ""
    end

    [:get, :post, :put, :patch, :delete].each do |m|
      define_method(m) do |action, *args|
        @response = nil
        @response = Cargobull::Dispatch.call(m, action, *args)
      end
    end
  end
end
