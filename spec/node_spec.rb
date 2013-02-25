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

describe JasmineParser::Node do

  before(:each) do
    @node_info = {
       :name => "Node Name",
       :line => 1,
       :filename   => "foo.txt"
    }
  end

  describe "Node object" do

    before(:each) do
      @parent_node = JasmineParser::Node.new @node_info.merge({:name => "Parent Node"})

      @child1 = JasmineParser::Node.new @node_info.merge({:name => "Child 1"})
      @child2 = JasmineParser::Node.new @node_info.merge({:name => "Child 2"})

    end

    it "should be able to create a new node with all the info" do
      node = JasmineParser::Node.new @node_info

      node.name.should == @node_info[:name]
      node.line.should == @node_info[:line]
      node.filename.should == @node_info[:filename]
    end

    it "should accept children nodes" do
      @parent_node.children << @child1
      @parent_node.children << @child2

      @parent_node.children.size.should == 2
      @parent_node.children.first.should == @child1
      @parent_node.children.last.should == @child2
    end

    it "should accept a parent node" do
      child_with_parent = JasmineParser::Node.new @node_info.merge({:parent => @parent_node})
      child_with_parent.parent.should == @parent_node
    end


  end


  describe "Node Creation by type" do

    it "should create a root node" do
      node = JasmineParser::Node.root @node_info
      node.type.should == :root
    end

    it "should accept describe nodes" do
      node = JasmineParser::Node.describe @node_info
      node.type.should == :group
    end

    it "should accept context nodes" do
      node = JasmineParser::Node.context @node_info
      node.type.should == :group
    end

    it "should accept it nodes" do
      node = JasmineParser::Node.it @node_info
      node.type.should == :it
    end

  end
end