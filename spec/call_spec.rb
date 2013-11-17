require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
  class X
    def self.foo(*args)
    end

    def self.bar
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

  it "should allow breaking lines after point" do

    X.should_receive(:foo).and_return(X)
    to_run = <<-END
    # Following 3 lines should do the same thing twice
    X.foo()
      .bar()
    END
    PartialRuby.eval(to_run, binding)
  end
end