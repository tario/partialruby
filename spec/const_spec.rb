require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do
  def self.test_const_read(*const_names)
    const_names.each do |const_name|
      it "should read constant of name #{const_name}" do
        eval("#{const_name} = 9")
        PartialRuby.eval("#{const_name}", binding).should be == 9
      end
    end
  end

  def self.test_const_assign(*const_names)
    const_names.each do |const_name|
      it "should assign constant of name #{const_name}" do
        PartialRuby.eval("#{const_name} = 10", binding)
        eval("#{const_name}").should be == 10
      end
    end
  end

  test_const_read "TEST_CONST"
  test_const_assign "TEST_CONST2"

  test_const_read "Fixnum::TEST_CONST"
  test_const_assign "Fixnum::TEST_CONST2"

  test_const_read "::TEST_CONST3"
  test_const_assign "::TEST_CONST4"

end