require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.test_classname(classname)
    it "should declare class with name #{classname}" do
      PartialRuby.eval("class #{classname}; end", binding)
      newclass = eval(classname)
      newclass.should be == newclass
    end
  end

  def self.test_modulename(modulename)
    it "should declare module with name #{modulename}" do
      PartialRuby.eval("module #{modulename}; end", binding)
      newmodl = eval(modulename)
      newmodl.should be == newmodl
    end

  end

  test_classname "X"

  module TestModuleA
  end
  test_classname "TestModuleA::X"
  test_classname "::X"

  test_modulename "TestModuleA::Y"
  test_modulename "::Y"

end