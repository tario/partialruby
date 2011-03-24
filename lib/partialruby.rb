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

    def ruby_emul(tree)
      nodetype = tree.first
      send("ruby_emul_"+nodetype.to_s, tree)
    end

    def emul(tree)
      begin
        # first, try to emul the node
        return ruby_emul(tree)
      rescue NoMethodError => e
        if tree
          "#{object_ref self}.run(#{object_ref tree}, PartialRuby::Frame.new(binding,self) )"
        else
          "nil; "
        end
      end
    end

    def run(tree, frame)
      return nil unless tree

      nodetype = tree.first

      code = nil
      begin
        # first, try to emul the node
        code = ruby_emul(tree)
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

    def ruby_emul_nil(tree)
      "(nil)"
    end

    def ruby_emul_scope(tree)
      emul tree[1]
    end

    def ruby_emul_block(tree)
      last = nil

      code = ""
      tree[1..-1].each do  |subtree|
        code << emul(subtree) << "\n"
      end

      code
    end

    def ruby_emul_hash(tree)
      pairs = Array.new
      (0..((tree.size - 1) / 2)-1).each do |i|
        pairs << [ tree[i*2+1], tree[i*2+2] ]
      end

      "{" + pairs.map{|pair| "(#{emul pair.first})=>(#{emul pair.last} )" }.join(",") + "}"
    end

#    def handle_node_block(tree, frame)
 #     last = nil
  #    tree[1..-1].each do  |subtree|
   #     last = run(subtree, frame)
    #  end

     # last
    #end

    def ruby_emul_lasgn(tree)
      varname = tree[1]
      "#{varname} = ( #{emul(tree[2])} );"
    end

    def ruby_emul_lvar(tree)
      varname = tree[1]
      varname.to_s
    end

    def ruby_emul_const(tree)
      tree[1].to_s
    end

    def ruby_emul_colon3(tree)
      "::" + tree[1].to_s
    end

    def ruby_emul_colon2(tree)
      "#{emul tree[1]}::#{tree[2]}"
    end

    def ruby_emul_class(tree)
        classtree = tree[1]
        subtree = tree[3]

        classname = ""
        if classtree.instance_of? Symbol then
          classname = classtree
        else
          classname = emul classtree
        end

        return ("
          class #{classname}
            #{emul subtree}
          end
        ")
    end

    def ruby_emul_defn(tree)
      method_name = tree[1]
      args = tree[2]
      impl = tree[3][1]

      "def #{method_name}
          #{emul impl}
        end
      "
    end

    def ruby_emul_lit(tree)
      "(#{object_ref tree[1]})"
    end

    def ruby_emul_str(tree)
      "(#{object_ref tree[1]})"
    end

    def ruby_emul_array(tree)
      "[" + tree[1..-1].map{ |subtree| "(" + emul(subtree) + ")" }.join(",") + "]"
    end

    def ruby_emul_self(tree)
      "(self)"
    end

    def ruby_emul_true(tree)
      "true"
    end

    def ruby_emul_false(tree)
      "false"
    end

    def ruby_emul_if(tree)
      "if (#{emul tree[1]}); (#{emul tree[2]}) else (#{emul tree[3]}) end"
    end

    def ruby_emul_while(tree)
      "while (#{emul tree[1]}); (#{emul tree[2]}); end "
    end

    def process_args(tree)
      nodetype = tree[0]
      if nodetype == :lasgn
        tree.last.to_s
      elsif nodetype == :masgn
        tree[1][1..-1].map {|subtree|
          process_args(subtree)
        }.join(",")
      elsif nodetype == :splat
        "*" + process_args(tree.last)
      end

    end

    def ruby_emul_iter(tree)
      callnode = tree[1]
      innernode = tree[3]

      arguments = tree[2]
      argumentsstr = ""

      if arguments
        argumentsstr = "|" + process_args(arguments) + "|"
      end
      "#{emul callnode} { #{argumentsstr} #{emul innernode} }"
    end

    def ruby_emul_until(tree)
      "until (#{emul tree[1]}); (#{emul tree[2]}); end "
    end

    def ruby_emul_case(tree)
      str = "case #{emul tree[1]}; "

      tree[2..-2].each do |subtree|
        matches = subtree[1][1..-1].map{|subsubtree| "(" + emul(subsubtree) + ")" }.join(",")

        str << "when #{matches}; #{emul subtree[2]};"
      end

      if tree[-1]
        str << "else; #{emul tree[-1]}; "
      end

      str << "end; "
      str
    end

    def ruby_emul_splat(tree)
      "*(#{emul(tree[1])})"
    end

    def ruby_emul_ensure(tree)
      "begin;
         #{emul tree[1]}
      ensure;
        #{emul tree[2] }
      end;
      "
    end

    def ruby_emul_rescue(tree)

      resbody = tree[2][2]

      strresbody = ""
      if resbody
        strresbody = emul resbody
      else
        strresbody = ""
      end

      exceptionarray = tree[2][1][1..-1]

      exceptionstrarray = []

      i = 0
      while i < exceptionarray.size
        if exceptionarray[i+1]
          if exceptionarray[i+1][0] == :lasgn
           exceptionstrarray << "(" + (emul(exceptionarray[i]) + ") => " + exceptionarray[i+1][1].to_s)
            i = i + 1
          else
            exceptionstrarray << "(" + (emul(exceptionarray[i])) + ")"
          end
        else
          exceptionstrarray << "(" + (emul(exceptionarray[i])) + ")"
        end
        i = i + 1
      end

      "begin;
        #{emul tree[1]}
      rescue #{exceptionstrarray.join(",")};
        #{strresbody}
      end;
      "
    end

    def ruby_emul_call(tree)
        object_tree = tree[1]
        method_name = tree[2]

        arglisttree = tree[3]
        arglist = arglisttree[1..-1]

        argsstr = arglist.
              map{|subtree|
                if subtree[0] == :splat
                  emul(subtree)
                else
                  "(" +  emul(subtree) + ")"
                end
                 }.
              join(",")

        if (object_tree)
          if arglist.count == 0
          "(#{emul(object_tree)}).#{method_name}"
          else
          "(#{emul(object_tree)}).#{method_name}(#{argsstr})"
          end
        else
          if arglist.count == 0
          "#{method_name}"
          else
          "#{method_name}(#{argsstr})"
          end
        end

    end
  end

#X.new.foo
end