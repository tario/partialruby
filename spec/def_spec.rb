require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.test_method_def(method_name, arguments=nil, arguments_value=nil)

    if arguments
      it "should define method of name #{method_name} with arguments #{arguments}: #{arguments_value}" do
        PartialRuby.eval("def #{method_name}(#{arguments}); end; #{method_name}(#{arguments_value})", binding)
      end
    else
      it "should define method of name #{method_name} with no arguments" do
        PartialRuby.eval("def #{method_name}; end; #{method_name}()", binding)
      end
    end
  end

  ["foo", "bar"].each do |method_name|
    test_method_def method_name
    { "a" => "1", "a,b" => "1,2"}.each do |k,v|
      test_method_def method_name, k, v
    end
  end

end