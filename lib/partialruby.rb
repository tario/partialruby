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
    c = PureRubyContext.new

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
      return nil unless tree

      nodetype = tree.first

      send("handle_node_"+nodetype.to_s, tree, frame)
    end
  end

  class PureRubyContext < Context

    def handle_node_scope(tree, frame)
      run(tree[1], frame)
    end

    def handle_node_block(tree, frame)
      last = nil
      tree[1..-1].each do  |subtree|
        last = run(subtree, frame)
      end

      last
    end

    def handle_node_class(tree, frame)
        classname = tree[1]
        subtree = tree[3]

        return eval("
          class #{classname}
            PureRubyContext.new.run(#{object_ref subtree}, Frame.new(binding,self) )
          end
        ", frame._binding)
    end

    def handle_node_defn(tree, frame)
      method_name = tree[1]
      args = tree[2]
      impl = tree[3][1]

      _self = frame._self

      eval("def #{method_name}
          PureRubyContext.new.run(#{object_ref impl}, Frame.new(binding,self) )
        end
      ", frame._binding)

    end

    def handle_node_str(tree, frame)
      tree[1]
    end

    def handle_node_call(tree, frame)
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
  end

#X.new.foo
end