class Llama
  include Cargobull::Service

  def read
    return :moo
  end
end

describe Cargobull::Dispatch do
  describe "method translation" do
    it "should allow only restful methods" do
      [:get, :post, :put, :patch, :delete].each do |m|
        begin
          Cargobull::Dispatch.translate_method_call(m)
          assert true
        rescue RuntimeError
          assert false
        end
      end
    end

    it "should not allow anything but restful method" do
      begin
        Cargobull::Dispatch.translate_method_call(:meow)
        assert false
      rescue RuntimeError
        assert true
      end
    end
  end

  describe "action translation" do
    it "should find the proper dispatch class" do
      assert_equal Llama, Cargobull::Dispatch.translate_action_call('llama')
    end

    it "should raise when the dispatch class does not exist" do
      begin
        Cargobull::Dispatch.translate_action_call('meow')
        assert false
      rescue RuntimeError
        assert true
      end
    end
  end

  describe "call" do
    it "should call registered methods and return data" do
      assert_equal :moo, Cargobull::Dispatch.call(:get, 'llama')
    end
  end
end
