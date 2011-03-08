require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.assert_ruby_expr(expr, expected = nil)

    expected ||= eval(expr)

    it "should return #{expected} on expresion #{expr}" do
      PartialRuby.eval(expr,binding).should be == expected
    end
  end

  assert_ruby_expr "if true; true; else; false; end"
  assert_ruby_expr "if true; true; else; true; end"
  assert_ruby_expr "if true; false; else; true; end"
  assert_ruby_expr "if true; false; else; false; end"

end