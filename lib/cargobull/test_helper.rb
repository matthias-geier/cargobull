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

    def assert_raise(except_klass)
      begin
        yield
      rescue except_klass
        assert true
        return
      end
      assert false
    end

    def assert_nothing_raised
      begin
        yield
        assert true
      rescue
        assert false
      end
    end
  end
end

include Cargobull::TestHelper
