require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.assert_ruby_expr(expr, expected = nil)

    expected ||= eval(expr)

    it "should return #{expected} on expresion #{expr}" do
      PartialRuby.eval(expr,binding).should be == expected
    end
  end

  def self.test_operators(*ops)
    ops.each do |op|
      assert_ruby_expr "2.0#{op}3.0"
    end
  end

  test_operators "+", "-", "/", "*", "**"

end