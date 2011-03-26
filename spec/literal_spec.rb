require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.assert_ruby_expr(expr, expected = nil)

    expected ||= eval(expr)

    it "should return #{expected} on expresion #{expr}" do
      PartialRuby.eval(expr,binding).should be == expected
    end
  end

  assert_ruby_expr "'xxx'"
  assert_ruby_expr "43"
  assert_ruby_expr "(0..9)"
  assert_ruby_expr "{ 1 => 2, 3 => 4 }"
  assert_ruby_expr "[1,2,3,4,5]"
  assert_ruby_expr "/aaa/"

  assert_ruby_expr 'a="x"; "xxxxx#{a}"'
end