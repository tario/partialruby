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
        PartialRuby.eval(expr,binding).to_s.should be == expected.to_s
      end
    end
  end

  assert_ruby_expr("raise Exception")
  assert_ruby_expr("begin; raise Exception; rescue; 5; end")
  assert_ruby_expr("begin; raise Exception; rescue Exception; 4; end")
  assert_ruby_expr("begin; raise Exception; rescue Exception => e; 9; ensure; 4; end")
  assert_ruby_expr("begin; raise '999'; rescue RuntimeError; end")
  assert_ruby_expr("begin; raise '999'; rescue RuntimeError; end; 5")
  assert_ruby_expr("begin; raise '999'; rescue RuntimeError, Exception; end")
  assert_ruby_expr("begin; raise '999'; rescue RuntimeError, Exception; end; 5")

  [
   "rescue RuntimeError; end",
   "rescue RuntimeError => e; end",
   "rescue Errno::EINVAL; end",
   "rescue Errno::EINVAL => e; end",
   "rescue RuntimeError, Errno::EINVAL; end",
   "rescue RuntimeError, Errno::EINVAL => e; e; end",
  ].each do |x|
  assert_ruby_expr("begin; raise Errno::EINVAL; #{x}")
  assert_ruby_expr("begin; raise RuntimeError; #{x}")
  assert_ruby_expr("begin; raise Errno::EINVAL; #{x}")
  assert_ruby_expr("begin; raise RuntimeError; #{x}")
  end

end
