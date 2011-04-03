require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
  it "should read constant" do
    TEST_CONST = 9
    PartialRuby.eval("TEST_CONST", binding).should be == 9
  end

  it "should assign constant" do
    PartialRuby.eval("TEST_CONST_2 = 10", binding)
    TEST_CONST_2.should be == 10
  end

end