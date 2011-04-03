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

  def self.test_block_arguments(args, args_result)
    it "should pass block statements with arguments #{args_result}" do
      BlockTest.should_receive(:bar).with(*args_result)
      PartialRuby.eval("BlockTest.foo(#{args}) { |*x| BlockTest.bar(*x) }", binding)
    end
  end

  test_block_argument "1", [1]
  test_block_argument "'test'", ["test"]

  test_block_arguments "1,2", [1,2]
  test_block_arguments "'test',2", ["test",2]

  it "should implement yield statement" do
    def foo
      PartialRuby.eval("yield", binding)
    end
    foo{}
  end

  it "should implement yield statement with one argument" do
    def foo_2
      PartialRuby.eval("yield(4)", binding)
    end

    a = nil
    foo_2{|x| a = x }
    a.should be == 4
  end

  it "should implement yield statement with two argument" do
    def foo_2
      PartialRuby.eval("yield(4,5)", binding)
    end

    a = nil
    b = nil
    foo_2{|x,y| a = x; b = y }
    a.should be == 4
    b.should be == 5
  end

  it "should implement yield statement with multiple arguments" do
    def foo_2
      x = [4,5]
      PartialRuby.eval("yield(*x)", binding)
    end

    a = nil
    b = nil
    foo_2{|x,y| a = x; b = y }
    a.should be == 4
    b.should be == 5
  end

end