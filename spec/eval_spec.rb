require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
	it "should eval hello world string" do
		PartialRuby.eval 'print "hello world\n"', binding
	end

  it "should define a class" do
    PartialRuby.eval 'class X; end', binding
  end

  it "should define a class with a method" do
    PartialRuby.eval 'class X; def foo; end; end', binding
  end

end
