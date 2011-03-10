require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
  class X
    def self.foo(*args)
    end
  end

  it "should make call without arguments" do

    X.should_receive(:foo)
    PartialRuby.eval("X.foo", binding)
  end

  def self.test_args(args, args_result)
    it "should make call without arguments #{args} and receive #{args_result.inspect}" do

      X.should_receive(:foo).with(*args_result)
      PartialRuby.eval("X.foo(#{args})", binding)
    end
  end

  test_args "1,2,3", [1,2,3]
end