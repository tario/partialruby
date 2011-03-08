require "partialruby"

include PartialRuby

class MyContext < PureRubyContext
	
	def ruby_emul_call(tree,frame)
		receiver = tree[1] || s(:self)
		
		unless tree[1][1] == self
			tree[1] = s(:call, s(:lit, self), :hook_method_recv, s(:arglist, receiver, s(:lit, tree[2]) ) )
		end
		
		super(tree, frame)
	end
	
	def hook_method_recv(recv, method_name)
		
		print "called #{method_name} over #{recv}\n"
		
		recv
	end
end

class X
	def foo
		print "foo\n"
	end
end

context = MyContext.new
tree = RubyParser.new.parse "X.new.foo()"

context.run(tree, Frame.new(binding,self))
#code = context.emul(tree, Frame.new(binding,self))
