=begin

This file is part of the partialruby project, http://github.com/tario/partialruby

Copyright (c) 2010 Roberto Dario Seminara <robertodarioseminara@gmail.com>

partialruby is free software: you can redistribute it and/or modify
it under the terms of the gnu general public license as published by
the free software foundation, either version 3 of the license, or
(at your option) any later version.

partialruby is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.  see the
gnu general public license for more details.

you should have received a copy of the gnu general public license
along with partialruby.  if not, see <http://www.gnu.org/licenses/>.

=end
require "rubygems"
require "ruby_parser"

module PartialRuby

  def self.eval(code, b_)
    c = Context.new

    parser = RubyParser.new
    c.run(parser.parse(code), Frame.new(b_, b_.eval("self")) )
  end

  class Frame
    attr_reader :_binding
    attr_reader :_self

    def initialize(b, _self)
      @_binding = b
      @_self = _self
    end
  end

  class Context


    def object_ref(obj)
      "ObjectSpace._id2ref(#{obj.object_id})"
    end


    def run(tree, frame)
      nodetype = tree.first

      if nodetype == :scope
        return run(tree[1], frame)
      end

      if nodetype == :class
        classname = tree[1]
        subtree = tree[3]

        return eval("
          class #{classname}
            Context.new.run(#{object_ref subtree}, Frame.new(binding,self) )
          end
        ", frame._binding)
      end

      if nodetype == :block

        last = nil
        tree[1..-1].each do  |subtree|
          last = run(subtree, frame)
        end

        return last
      end

      if nodetype == :defn
        method_name = tree[1]
        args = tree[2]
        impl = tree[3][1]

        _self = frame._self

        eval("def #{method_name}
            Context.new.run(#{object_ref impl}, Frame.new(binding,self) )
          end
        ", frame._binding)

        return
      end

      if nodetype == :call
        object_tree = tree[1]

        if object_tree then
          recv = run(object_tree, frame)
        else
          recv = frame._self
        end

        method_name = tree[2]

        arglist = tree[3]

        args = Array.new

        arglist[1..-1].each do |subtree|
          args << run(subtree, frame)
        end

        return recv.send(method_name, *args)

      end

      if nodetype == :str then
        return tree[1]
      end

      raise "Unkown node type :#{nodetype}\n"
    end
  end


#X.new.foo
end