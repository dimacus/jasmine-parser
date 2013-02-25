# Copyright (c) 2013, Groupon, Inc.
# All rights reserved. 
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met: 
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer. 
# 
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution. 
# 
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module JasmineParser

  class Node


    attr_reader :name, :line, :filename, :js_object
    attr_accessor :parent, :children
    def initialize(args)

      @name       = args[:name]
      @line       = args[:line]
      @parent     = args[:parent]
      @children   = args[:children]   || []
      @filename   = args[:filename]
      @js_object  = args[:js_object]

    end

    def type
      raise UndefinedMethodError
    end

    def self.root(args)
      RootNode.new args
    end

    def self.it(args)
      ExampleNode.new args
    end

    def self.group(args)
      GroupNode.new args
    end

    class << self
     alias context group
     alias describe group
    end

    def self.shared_behavior_declaration(args)
      SharedBehaviorDeclaration.new args
    end

    def self.shared_behavior_invocation(args)
      SharedBehaviorInvocation.new args
    end

    def self.function_invocation(args)
      FunctionInvocation.new args
    end

    def clone
      args = {
        :name      => name,
        :line      => line,
        :parent    => parent,
        :children  => [],
        :filename  => filename,
        :js_object => js_object
      }

      new_clone = Node.send(self.type, args)

      self.children.each do |child|
        new_clone.children << child.clone
      end

      update_the_parent_for_all_children(new_clone)
      
      new_clone
    end

    def formatted_name
      name + " "
    end

    def ready_to_be_adopted?
      true
    end

    private

    def update_the_parent_for_all_children(node)
      node.children.each do |child|
        child.parent = node
      end
    end
  end

end