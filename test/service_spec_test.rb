class Mule
  include Cargobull::Service
end

class Donkey
end

describe Mule do
  it "dispatcher should register classes with included module" do
    assert Cargobull::Service.dispatch_to("mule")
  end

  it "dispatcher should not register classes without included module" do
    refute Cargobull::Service.dispatch_to("donkey")
  end
end
