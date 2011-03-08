require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.assert_ruby_expr(expr, expected = nil)

    expected ||= eval(expr)

    it "should return #{expected} on expresion #{expr}" do
      PartialRuby.eval(expr,binding).should be == expected
    end
  end

  def self.test_if(keyword)
    assert_ruby_expr keyword + " true; true; else; false; end"
    assert_ruby_expr keyword + " true; true; else; true; end"
    assert_ruby_expr keyword + " true; false; else; true; end"
    assert_ruby_expr keyword + " true; false; else; false; end"
  end

  test_if "if"
  test_if "unless"

  assert_ruby_expr "i = 5 ; while(i>0); i=i-1; end; i"
  assert_ruby_expr "i = 5 ; until(i==0); i=i-1; end; i"


  (1..4).each do |x|
  assert_ruby_expr "case #{x}; when 1; 2; end"
  assert_ruby_expr "case #{x}; when 1; 2; when 2; 3; end"
  assert_ruby_expr "case #{x}; when 1; 2; when 2; 3; end"
  assert_ruby_expr "case #{x}; when 1; 2; when 2; 3; when 3; 4; else; 9; end"
  assert_ruby_expr "case #{x}; when (if true; 1; else; false; end),9; 2; when 2; 3; else; 9; end"
  end

end