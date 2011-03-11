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

  def self.test_block_arguments(args, args_result)
    it "should pass block statements with arguments #{args_result}" do
      BlockTest.should_receive(:bar).with(*args_result)
      PartialRuby.eval("BlockTest.foo(#{args}) { |x,y| BlockTest.bar }", binding)
    end
  end

  test_block_arguments "1", [1]
  test_block_arguments "1,2", [1,2]
  test_block_arguments "'test'", ["test"]

end