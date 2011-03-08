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

  it "should define a class with a method and the method must be callable" do

    module TestClassWithFoo2
    PartialRuby.eval 'class X; def foo; end; end', binding
    end

    x = TestClassWithFoo2::X.new
    x.foo.should be == nil
  end

  it "should define a class with two methods and the methods must be callable" do

    module TestClassWithFoo3
    PartialRuby.eval 'class X; def foo; end; def bar; end; end', binding
    end

    x = TestClassWithFoo3::X.new
    x.foo.should be == nil
    x.bar.should be == nil
  end

   # This does not work in the original ruby!
#  it "should write a local variable" do
 #   PartialRuby.eval "a = 5", binding
  #  a.should be == 5
#  end

  def self.test_local_with_value(value)
    it "should allow represent literal #{value}" do
      PartialRuby.eval(value, binding).should be == eval(value)
    end

    it "should read a local variable with value #{value}" do
      a = eval(value)
      PartialRuby.eval("a", binding).should be == eval(value)
    end

    it "should declare and read a local variable with value #{value}" do
      PartialRuby.eval("a = #{value}; a", binding).should be == eval(value)
    end
  end

  test_local_with_value "5"
  test_local_with_value "5.5"
  test_local_with_value "'teststring'"
  test_local_with_value "[5]"
  test_local_with_value "[5,6,7,8,9]"
  test_local_with_value "[[9,6],7,8,9]"

  test_local_with_value "{ 1 => 3, 5 => 9}"


end
