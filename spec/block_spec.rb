require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  class BlockTest
    def self.foo
      yield
    end

    def self.xoo
    end
  end

  it "should pass block statements" do
    BlockTest.should_receive :foo
    BlockTest.should_receive :xoo
    PartialRuby.eval("BlockTest.foo{ BlockTest.xoo }", binding)
  end
end