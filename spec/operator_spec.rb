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

  assert_ruby_expr "[1][0]"

  values = ["true", "false"]
  ops = ["and", "or", "&&", "||", "=="]

  values.each do |value1|
      assert_ruby_expr "not #{value1}"
      assert_ruby_expr "!#{value1}"
  values.each do |value2|
    ops.each do |op|
      assert_ruby_expr "#{value1} #{op} #{value2}"
    end
  end
  end

end