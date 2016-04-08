class Mule
  include Cargobull::Service
end

module Nested
  class Mule
    include Cargobull::Service
  end
end

class Donkey
end

describe Mule do
  it "dispatcher should register classes with included module" do
    assert Cargobull::Service.dispatch_to("mule")
  end

  it "dispatcher should register nested classes with included module" do
    assert Cargobull::Service.dispatch_to("nested/mule")
  end

  it "dispatcher should not register classes without included module" do
    refute Cargobull::Service.dispatch_to("donkey")
  end
end
