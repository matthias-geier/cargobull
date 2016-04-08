class Buffalo
  extend Cargobull::TestHelper
end

class Bow
  include Cargobull::Service

  def read(p); "worked"; end
  def create(p); "worked"; end
  def update(p); "worked"; end
  def delete(p); "worked"; end
end

describe Buffalo do
  before do
    @env = Cargobull.env.get
  end

  [:get, :post, :put, :patch, :delete].each do |m|
    it "should respond to #{m}" do
      assert Buffalo.respond_to?(m)
    end

    it "should forward the call for #{m} to Bow" do
      assert_equal [200, { "Content-Type" => "text/plain" }, "worked"],
        Buffalo.send(m, @env, "bow", {})
    end

    it "should forward the call for #{m} to Bow and pass it into a block" do
      Buffalo.send(m, @env, "bow", {}) do |r|
        assert_equal [200, { "Content-Type" => "text/plain" }, "worked"], r
      end
    end
  end
end
