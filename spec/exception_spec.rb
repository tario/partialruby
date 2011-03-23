require "partialruby"

include PartialRuby

describe Context, "PartialRuby context" do

  def self.assert_ruby_expr(expr, expected = nil)

    exception = nil

    begin
      expected ||= eval(expr)
    rescue Exception => e
      exception = e
    end

    if exception
      it "should raise #{exception} on expresion #{expr}" do
        lambda{
          PartialRuby.eval(expr,binding)
        }.should raise_error(exception.class)
      end
    else
      it "should return #{expected} on expresion #{expr}" do
        PartialRuby.eval(expr,binding).should be == expected
      end
    end
  end

  assert_ruby_expr("raise Exception")
  assert_ruby_expr("begin; raise Exception; rescue; 5; end")
  assert_ruby_expr("begin; raise Exception; rescue Exception; 4; end")
  assert_ruby_expr("begin; raise Exception; rescue Exception => e; 9; ensure; 4; end")
end
