require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  it "should eval literal 'hello world'" do
    PartialRuby.eval('"hello world"', binding).should be == "hello world"
  end

	it "should eval hello world string" do
		PartialRuby.eval 'print "hello world\n"', binding
	end

  it "should define a class" do

    module TestEmptyClass
    PartialRuby.eval 'class X; end', binding
    end

    TestEmptyClass::X.should be == TestEmptyClass::X
  end

  it "should define a class with a method" do

    module TestClassWithFoo
    PartialRuby.eval 'class X; def foo; end; end', binding
    end

    TestClassWithFoo::X.should be == TestClassWithFoo::X
  end

  it "should write a local variable" do
    PartialRuby.eval "a = 5", binding
    a.should be == 5
  end

  it "should read a local variable" do
    a = 5
    PartialRuby.eval("a", binding).should be == 5
  end

  it "should declare and read a local variable" do
    PartialRuby.eval("a = 5; a", binding).should be == 5
  end

end
