require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
	it "should eval hello world string" do
		PartialRuby.eval 'print "hello world\n"', binding
	end
end
