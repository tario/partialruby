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

  assert_ruby_expr "i = 5 ; while(i>0); i=i-1; end; i"
  assert_ruby_expr "i = 5 ; until(i==0); i=i-1; end; i"

  assert_ruby_expr "case 1; when 1; 2; end"
  assert_ruby_expr "case 2; when 1; 2; when 2; 3; end"
  assert_ruby_expr "case 1; when 1; 2; when 2; 3; end"
  assert_ruby_expr "case 1; when 1; 2; when 2; 3; when 3; 4; end"
  assert_ruby_expr "case 2; when 1; 2; when 2; 3; when 3; 4; end"
  assert_ruby_expr "case 3; when 1; 2; when 2; 3; when 3; 4; end"
  assert_ruby_expr "case 4; when 1; 2; when 2; 3; when 3; 4; else; 9; end"
end