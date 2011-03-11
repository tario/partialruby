require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  class BlockTest
    def self.foo
      yield
    end

    def self.bar
    end
  end

  it "should pass block statements" do
    BlockTest.should_receive :foo
    BlockTest.should_receive :bar
    PartialRuby.eval("BlockTest.foo{ BlockTest.bar }", binding)
  end
end