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

require 'spec_helper'
require 'shared_examples_for_end_to_end'

describe JasmineParser::FileParser do
  before(:each) do
    @suite = JasmineParser::JasmineSuite.new
    @parser = JasmineParser::FileParser.new(@suite)
    @filename = "spec/fixture/spec/shared_examples_function_declaration_spec.js"
    @parser.parse ["spec/fixture/spec/shared_examples_function_declaration_spec.js"]
    @file = @suite.spec_files.first
    @invocation_node = @file.children.first.children.first.children.first
  end


  describe "shared examples declared in a function" do

    describe "parsing of the file" do

      

      it "should move the shared function declaration to invocation node" do
        @invocation_node.name.should == "group 2"
        @invocation_node.type.should == :group
        @invocation_node.line.should == 29
        @invocation_node.children.first.name.should == "sharedBehaviorInFunction"
        @invocation_node.children.first.children.size.should == 1
        @invocation_node.children.first.children.first.name.should == "(shared)"
      end

      it "should not have any decoy functions" do
        @file.children.size.should == 1
        @file.children.last.name.should == "shared example declared in new function"

        @file.children.first.children.first.children.size.should == 2

        @file.children.first.children.first.children.first.name.should == "group 2"
        @file.children.first.children.first.children.last.name.should == "group 3"
      end

    end

  end

end