class Llama
  include Cargobull::Service

  def read(params)
    :moo
  end

  def create(params)
    params
  end
end

module Nested
  class Llama
    include Cargobull::Service
  end
end

describe Cargobull::Dispatch do
  before do
    @env = Cargobull.env.get
  end

  describe "method translation" do
    it "should allow only restful methods" do
      ["GET", "POST", "PATCH", "PUT", "DELETE"].each do |m|
        assert Cargobull::Dispatch.translate_method_call(@env, m).is_a?(Symbol)
      end
    end

    it "should not allow anything but restful method" do
      assert_equal [405, { "Content-Type" => @env[:ctype] }, @env[:e405] ],
        Cargobull::Dispatch.translate_method_call(@env, "MEOW")
    end
  end

  describe "action translation" do
    it "should find the proper dispatch class name" do
      assert_equal "Llama",
        Cargobull::Dispatch.translate_action_call(@env, 'llama')
    end

    it "should find the proper nested dispatch class name" do
      assert_equal "Nested::Llama",
        Cargobull::Dispatch.translate_action_call(@env, 'nested/llama')
    end

    it "should error when the class to dispatch to does not exist" do
      assert_equal [404, { "Content-Type" => @env[:ctype] }, @env[:e404] ],
        Cargobull::Dispatch.translate_action_call(@env, 'meow')
    end
  end

  describe "call" do
    it "should call registered methods and return data" do
      assert_equal [200, { "Content-Type" => "text/plain" }, :moo],
        Cargobull::Dispatch.call(@env, "GET", 'llama', {})
    end

    it "should transform input data as specified in the transform block" do
      @env[:transform_in] = ->(arg){ { :mykey => arg } }
      assert_equal [200, { "Content-Type" => "text/plain" },
        { :mykey => :moo }],
        Cargobull::Dispatch.call(@env, "POST", 'llama', :moo)
    end

    it "should transform output data as specified in the transform block" do
      @env[:transform_out] = ->(code=nil, headers=nil, body) do
        { :mykey => body }
      end
      assert_equal [200, { "Content-Type" => "text/plain" },
        { :mykey => :moo }],
        Cargobull::Dispatch.call(@env, "POST", 'llama', :moo)
    end
  end
end
