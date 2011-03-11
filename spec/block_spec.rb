require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  class BlockTest
    def self.foo(*args)
      yield(*args)
    end

    def self.bar(*args)
    end
  end

  it "should pass block statements" do
    BlockTest.should_receive :bar
    PartialRuby.eval("BlockTest.foo{ BlockTest.bar }", binding)
  end

  def self.test_block_argument(args, args_result)
    it "should pass block statements with arguments #{args_result}" do
      BlockTest.should_receive(:bar).with(*args_result)
      PartialRuby.eval("BlockTest.foo(#{args}) { |x| BlockTest.bar(x) }", binding)
    end
  end

  test_block_argument "1", [1]
  test_block_argument "'test'", ["test"]

end