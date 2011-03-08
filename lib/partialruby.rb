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
    attr_reader :locals

    def initialize(b, _self)
      @_binding = b
      @_self = _self
      @locals = Hash.new
    end
  end

  class Context
    def object_ref(obj)
      "ObjectSpace._id2ref(#{obj.object_id})"
    end

    def ruby_emul(tree, frame)
      nodetype = tree.first
      send("ruby_emul_"+nodetype.to_s, tree, frame)
    end

    def emul(tree, frame)
      begin
        # first, try to emul the node
        return ruby_emul(tree, frame)
      rescue NoMethodError => e
        "#{object_ref self}.run(#{object_ref tree}, PartialRuby::Frame.new(binding,self) )"
      end
    end

    def run(tree, frame)
      return nil unless tree

      nodetype = tree.first

      code = nil
      begin
        # first, try to emul the node
        code = ruby_emul(tree, frame)
      rescue NoMethodError => e
      end

      if code then
        eval(code, frame._binding)
      else
        send("handle_node_"+nodetype.to_s, tree, frame)
      end
    end
  end

  class PureRubyContext < Context

#    def handle_node_scope(tree, frame)
 #     run(tree[1], frame)
  #  end

    def ruby_emul_nil(tree, frame)
      "(nil)"
    end

    def ruby_emul_scope(tree, frame)
      emul tree[1], frame
    end

    def ruby_emul_block(tree, frame)
      last = nil

      code = ""
      tree[1..-1].each do  |subtree|
        code << emul(subtree, frame) << "\n"
      end

      code
    end

    def ruby_emul_hash(tree, frame)
      pairs = Array.new
      (0..((tree.size - 1) / 2)-1).each do |i|
        pairs << [ tree[i*2+1], tree[i*2+2] ]
      end

      "{" + pairs.map{|pair| "(#{emul pair.first, frame})=>(#{emul pair.last, frame} )" }.join(",") + "}"
    end

#    def handle_node_block(tree, frame)
 #     last = nil
  #    tree[1..-1].each do  |subtree|
   #     last = run(subtree, frame)
    #  end

     # last
    #end

    def ruby_emul_lasgn(tree, frame)
      varname = tree[1]
      "#{varname} = ( #{emul(tree[2], frame)} );"
    end

    def ruby_emul_lvar(tree,frame)
      varname = tree[1]
      varname.to_s + ";"
    end

    def ruby_emul_const(tree, frame)
      tree[1].to_s
    end

    def ruby_emul_colon3(tree, frame)
      "::" + tree[1].to_s
    end

    def ruby_emul_colon2(tree, frame)
      "#{emul tree[1], frame}::#{tree[2]}"
    end

    def ruby_emul_class(tree, frame)
        classtree = tree[1]
        subtree = tree[3]

        classname = ""
        if classtree.instance_of? Symbol then
          classname = classtree
        else
          classname = emul classtree, frame
        end

        return ("
          class #{classname}
            #{emul subtree, frame}
          end
        ")
    end

    def ruby_emul_defn(tree, frame)
      method_name = tree[1]
      args = tree[2]
      impl = tree[3][1]

      "def #{method_name}
          #{emul impl, frame}
        end
      "
    end

    def ruby_emul_lit(tree, frame)
      "(#{object_ref tree[1]})"
    end

    def ruby_emul_str(tree, frame)
      "(#{object_ref tree[1]})"
    end

    def ruby_emul_array(tree, frame)
      "[" + tree[1..-1].map{ |subtree| "(" + emul(subtree, frame) + ")" }.join(",") + "]"
    end

    def ruby_emul_self(tree,frame)
      "(self)"
    end

    def ruby_emul_true(tree,frame)
      "true"
    end

    def ruby_emul_false(tree,frame)
      "false"
    end

    def ruby_emul_if(tree,frame)
      "if (#{emul tree[1], frame}); (#{emul tree[2], frame}) else (#{emul tree[3], frame}) end"
    end

    def ruby_emul_while(tree,frame)
      "while (#{emul tree[1], frame}); (#{emul tree[2], frame}); end "
    end

    def ruby_emul_until(tree,frame)
      "until (#{emul tree[1], frame}); (#{emul tree[2], frame}); end "
    end

    def ruby_emul_call(tree, frame)
        object_tree = tree[1]
        method_name = tree[2]

        arglist = tree[3]

        argsstr = arglist[1..-1].
              map{|subtree| "(" +  emul(subtree, frame) + ")" }.
              join(",")


        if (object_tree)
          "(#{emul(object_tree, frame)}).#{method_name}(#{argsstr})"
        else
          if arglist.count == 0
          "#{method_name}(#{argsstr})"
          else
          "#{method_name}"
          end
        end

    end
  end

#X.new.foo
end