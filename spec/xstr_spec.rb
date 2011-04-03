require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
  it "should call external commands with xstr" do
    PartialRuby.eval("`echo hello world`", binding).should be == "hello world\n"
  end

  it "should call external commands with dxstr" do
    PartialRuby.eval("text = 'hello world'; `echo \#{text}`", binding).should be == "hello world\n"
  end

end