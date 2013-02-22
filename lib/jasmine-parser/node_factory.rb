# Copyright (c) 2012, Groupon, Inc.
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
 #TODO: Add some tests for node factory
  class NodeFactory

    def self.create_node(args)
      self.verify(args)

      node = Node.send(args[:type], args)

      node.js_object.each do |js_node|
        begin
          child_node_line = JavascriptObjectWrapper.get_node_line js_node
          child_node_type = JavascriptObjectWrapper.get_node_type js_node
          child_node_name = JavascriptObjectWrapper.get_node_name js_node
        rescue => e
          #I know that blank rescue is the root of all evil
          #However, this is still early stages, and we have not run into every possibility to account for
          #So it would be bad to fail someone's test run because their file contains something we don't expect
          #This way, we just throw a warning that we had an issue, and update the parser to account for that scenario
          #In the future, remove this rescue once all of the types of nodes have been accounted for

          Announcer.warning("Had an issue parsing one of the children nodes, check jasmine-parser-error.log for details")
          File.open("jasmine-parser-error.log", "a") do |file|
            file.write "\n\n\n"
            file.write "#{Time.now}"
            file.write "Encountered error trying to parse one of the children nodes for #{node.filename} starting on line #{node.line}"
            file.write e
          end

        end


        if JavascriptObjectWrapper.lines_already_covered.include? child_node_line
          next
        else
          JavascriptObjectWrapper.lines_already_covered << child_node_line  
        end


        child_node_js_object = JavascriptObjectWrapper.get_expression_statement_nodes js_node
        child_node_js_object.shift #Delete the very first item in array, because it contains the whole self node in it.


        

        if Node.respond_to? child_node_type
          node.children << self.create_node({
           :name        => child_node_name,
           :line  => child_node_line,
           :type        => child_node_type,
           :js_object   => child_node_js_object,
           :filename    => node.filename,
           :parent      => node
          })
        end
      end

      node

    end

    def self.verify(args)
      raise NodeTypeCannotBeBlankOrNilError if (args[:type].nil? or args[:type] == "")
      raise NodeStartLineHasToBeIntegerOrNilError unless (args[:line].nil? or args[:line].kind_of?(Fixnum))
    end


    def self.parse_file(filename)

      full_page_js_object = JavascriptObjectWrapper.parse_file filename
      js_object  = JavascriptObjectWrapper.get_expression_statement_nodes full_page_js_object

      root_node = self.create_node({
       :name =>     "",
       :filename    => filename,
       :line  => 0,
       :type        => :root,
       :js_object   => js_object

      })

      root_node

    end


  end



end