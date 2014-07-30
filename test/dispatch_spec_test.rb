class Llama
  include Cargobull::Service

  def read
    return :moo
  end

  def create
    return @params
  end
end

describe Cargobull::Dispatch do
  describe "method translation" do
    it "should allow only restful methods" do
      [:get, :post, :put, :patch, :delete].each do |m|
        assert_nothing_raised do
          Cargobull::Dispatch.translate_method_call(m)
        end
      end
    end

    it "should not allow anything but restful method" do
      assert_raise RuntimeError do
        Cargobull::Dispatch.translate_method_call(:meow)
      end
    end
  end

  describe "action translation" do
    it "should find the proper dispatch class" do
      assert_equal Llama, Cargobull::Dispatch.translate_action_call('llama')
    end

    it "should raise when the class to dispatch to does not exist" do
      assert_raise RuntimeError do
        Cargobull::Dispatch.translate_action_call('meow')
      end
    end
  end

  describe "call" do
    it "should call registered methods and return data" do
      assert_equal :moo, Cargobull::Dispatch.call(:get, 'llama')
    end

    it "should transform input data as specified in the transform block" do
      Cargobull.env.transform_in = lambda{ |*args| { :mykey => args.first } }
      assert_equal({ :mykey => :moo },
        Cargobull::Dispatch.call(:put, 'llama', :moo))
      Cargobull.env.transform_in = nil
    end

    it "should transform output data as specified in the transform block" do
      Cargobull.env.transform_out = lambda{ |*args| { :mykey => args.first } }
      assert_equal({ :mykey => :moo },
        Cargobull::Dispatch.call(:put, 'llama', :moo))
      Cargobull.env.transform_out = nil
    end
  end
end
