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

describe JasmineParser::SharedBehaviorInvocation do

  before(:each) do
    @parent_node = JasmineParser::Node.describe({:name => "parent", :line => 1})


    @shared_invocation = JasmineParser::Node.shared_behavior_invocation({:name => "shared",
                                                                         :line => 3,
                                                                         :parent => @parent_node})

    @parent_node.children << JasmineParser::Node.it({:name => "old child 1", :parent => @parent_node})
    @parent_node.children << @shared_invocation
    @parent_node.children << JasmineParser::Node.it({:name => "old child 3", :parent => @parent_node})

    @parent_to_inherit_from = JasmineParser::Node.describe({:name => "other parent", :line => 1})


    @new_children = [
        JasmineParser::Node.describe({:name => "new child 1", :line => 2, :parent => @parent_to_inherit_from}),
        JasmineParser::Node.context({:name  => "new child 2", :line => 4, :parent => @parent_to_inherit_from}),
        JasmineParser::Node.describe({:name => "new child 3", :line => 6, :parent => @parent_to_inherit_from}),
        JasmineParser::Node.describe({:name => "new child 4", :line => 8, :parent => @parent_to_inherit_from})
    ]

    @parent_to_inherit_from.children = @new_children
  end


  describe "inheriting children" do

    context "exception handling" do
      it "should only accept nodes as arguments" do
        expect {@shared_invocation.adopt_children({})}.to raise_error JasmineParser::UnsupportedObjectType
        expect {@shared_invocation.adopt_children([])}.to raise_error JasmineParser::UnsupportedObjectType
        expect {@shared_invocation.adopt_children("")}.to raise_error JasmineParser::UnsupportedObjectType
      end
    end

    context "cloning children" do
      before(:each) do
        @shared_invocation.adopt_children @parent_to_inherit_from
      end

      it "should not set name to blank after inheriting" do
        @shared_invocation.name.should == "shared"
      end

      it "should have nil in formatted name" do
        @shared_invocation.formatted_name.should == nil
      end

      it "should inherit the children of another node" do
        @shared_invocation.children.size.should == 4
      end

      it "should copy the names of all children properly" do
        @shared_invocation.children[0].name.should == "new child 1"
        @shared_invocation.children[1].name.should == "new child 2"
        @shared_invocation.children[2].name.should == "new child 3"
        @shared_invocation.children[3].name.should == "new child 4"
      end

      it "should copy the lines of all children properly" do
        @shared_invocation.children[0].line.should == 2
        @shared_invocation.children[1].line.should == 4
        @shared_invocation.children[2].line.should == 6
        @shared_invocation.children[3].line.should == 8
      end

      it "should adjust the parent for all of the inherited children" do
        @shared_invocation.children[0].parent.should == @shared_invocation
        @shared_invocation.children[1].parent.should == @shared_invocation
        @shared_invocation.children[2].parent.should == @shared_invocation
        @shared_invocation.children[3].parent.should == @shared_invocation
      end

      it "should be able to reach new children from parent" do
        @parent_node.children[1].children[0].name.should == "new child 1"
        @parent_node.children[1].children[1].name.should == "new child 2"
        @parent_node.children[1].children[2].name.should == "new child 3"
        @parent_node.children[1].children[3].name.should == "new child 4"
      end

      it "should be able to reach parent from new children" do
        children = @shared_invocation.children
        children[0].parent.parent.should == @parent_node
        children[1].parent.parent.should == @parent_node
        children[2].parent.parent.should == @parent_node
        children[3].parent.parent.should == @parent_node
      end

    end

  end


end