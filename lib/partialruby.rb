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
require "ruby2ruby"

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

  class Packet
    def initialize(emulationcode) #:nodoc:
      @emulationcode = emulationcode
    end
    def run(binding_, name = "(eval)", line = 1)
      eval(@emulationcode, binding_, name, line)
    end
  end

  class Context

    def initialize
      @preprocessors = Array.new
    end

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

    def pre_process(&blk)
      @preprocessors << blk
    end

    def packet(code)
      tree = nil

      begin
        tree = RubyParser.new.parse code
      rescue
        raise SyntaxError
      end

      context = PartialRuby::PureRubyContext.new

      @preprocessors.each do |preprocessor|
        tree = preprocessor.call(tree)
      end

      emulationcode = context.emul tree

      PartialRuby::Packet.new(emulationcode)
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
    def emul(tree)
      Ruby2Ruby.new.process(tree)
    end

    def ruby_emul(tree)
      Ruby2Ruby.new.process(tree)
    end

  end

#X.new.foo
end