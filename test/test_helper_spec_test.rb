class Buffalo
  include Cargobull::TestHelper
end

describe Buffalo do
  describe "test helper method exist" do
    [:response, :get, :post, :put, :patch, :delete].each do |m|
      it "should respond to #{m}" do
        assert Buffalo.new.respond_to?(m)
      end
    end
  end
end
