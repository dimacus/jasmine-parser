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


require 'rkelly'
#TODO: Write tests for js wrapper
module JasmineParser
  class JavascriptObjectWrapper

    def self.parse_file(filename)
      self.lines_already_covered.clear
      parser = RKelly::Parser.new
      file_string = File.open(filename, "r").read
      parser.parse(file_string, filename)
    end


    def self.get_expression_statement_nodes(js_object)
      classes = [RKelly::Nodes::ExpressionStatementNode,
                 RKelly::Nodes::ReturnNode,
                 RKelly::Nodes::FunctionDeclNode]
      
      js_object.collect {|node| node if classes.include? node.class }.compact
    end

    def self.lines_already_covered
      @lines_already_covered ||= []
    end

    def self.get_node_type(node)
      #TODO: clean this mess up
      if self.is_function_invocation?(node)
        if self.is_reserved_word?(node)
          return node.value.value.value
        elsif self.is_shared_behavior_declaration?(node)
          return :shared_behavior_declaration
        elsif self.is_shared_behavior_invocation?(node)
          return :shared_behavior_invocation
        else
          return :function_invocation
        end
      elsif self.is_function_declaration?(node)
        return :shared_behavior_declaration
      end

      :not_supported #If we don't know what type of node it is, just ignore it
    end

    def self.get_node_line(node)
      if self.is_function_declaration?(node)
        return node.line 
      else
        return node.value.value.line if self.has_accessible_line?(node)
      end
      nil
    end

    def self.get_node_name(node)

      name = ""
      if self.is_function_invocation?(node)
        if self.is_shared_behavior_declaration?(node) or self.is_shared_behavior_invocation?(node) or self.is_reserved_word?(node)
          #ToDo: account for nodes that do not return a string in this case
          name = node.value.entries[3].value if node.value.entries[3].value.kind_of? String
        else
          name = node.value.value.value if node.value.value.value.kind_of? String
        end
      elsif self.is_function_declaration?(node)
        name = node.value
      end

      name = name.gsub(/^["']/, "").gsub(/['"]$/, "") #Strip off heading and trailing "' chars, but only those and nothing else
      name = name.gsub(/\\/, "") #Get rid of any \ characters, because they confuse ruby strings a whole lot
      name
    end

    private

    def self.has_accessible_line?(node)
      #TODO: Need some test cases for these, i believe the return nodes are the ones that screw us over
      return false unless node.value.respond_to? :value
      return false unless node.value.value.respond_to? :line
      true
    end

    def self.is_function_invocation?(node)
      node.value.kind_of? RKelly::Nodes::FunctionCallNode
    end

    def self.is_function_declaration?(node)
      node.kind_of? RKelly::Nodes::FunctionDeclNode
    end

    def self.is_shared_behavior_declaration?(node)
      Config.shared_behavior_declarations.include? node.value.value.value
    end

    def self.is_shared_behavior_invocation?(node)
      Config.shared_behavior_invocation.include? node.value.value.value
    end

    def self.is_reserved_word?(node)
      Config.reserved_group_example_words.include? node.value.value.value
    end



  end
end