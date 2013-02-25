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

    @original_node = JasmineParser::Node.root({:filename => "foo.txt"})

    @original_node.children << JasmineParser::Node.describe(:name => "describe", :parent => @original_node)
    @original_node.children.first.children << JasmineParser::Node.it(:name => "nested it", :parent => @original_node.children.first)
    @original_node.children << JasmineParser::Node.it(:name => "not nested it", :parent => @original_node)

    @new_node = @original_node.clone
  end

  it "should return same type of node as original" do
    @new_node.type.should == :root
    @new_node.filename.should == "foo.txt"
  end

  it "should have the same amount of top level children" do
    @new_node.children.size.should == 2
    @new_node.children.first.name.should == "describe"
    @new_node.children.first.type.should == :group
    @new_node.children.last.type.should == :it
    @new_node.children.last.name.should == "not nested it"
  end

  it "should have copied the nested child" do
    @new_node.children.first.children.first.type.should == :it
    @new_node.children.first.children.first.name.should == "nested it"
  end

  it "should not have any pointers to original node" do
    @original_node.object_id.should_not == @new_node.object_id
    @original_node.children.first.object_id.should_not == @new_node.children.first.object_id
    @original_node.children.last.object_id.should_not == @new_node.children.last.object_id
    @original_node.children.first.children.first.object_id.should_not == @new_node.children.first.children.first.object_id
  end

  context "types of nodes to be cloned" do

    before(:each) do
      @node_types = {
          :root                        => :root,
          :it                          => :it,
          :context                     => :group,
          :describe                    => :group,
          :group                       => :group,
          :shared_behavior_declaration => :shared_behavior_declaration,
          :shared_behavior_invocation  => :shared_behavior_invocation
      }
    end

    it "should support cloning of all node types" do
      @node_types.keys.each do |key|
        original = JasmineParser::Node.send(key, {:name => "node"})
        new_node = original.clone
        new_node.type.should == @node_types[key]
      end
    end

  end

  context "updating parent of the newly cloned children" do
    before(:each) do
      @new_node_id = @new_node.object_id
      @new_node_first_child_id = @new_node.children.first.object_id
      @new_node_first_childs_child_id = @new_node.children.first.children.first.object_id
      @new_node_last_child_id = @new_node.children.last.object_id

    end

    it "should not point to any objects on original node" do
      @original_node.object_id.should_not == @new_node_id
      @original_node.children.first.object_id.should_not == @new_node_first_child_id
      @original_node.children.last.object_id.should_not == @new_node_last_child_id
      @original_node.children.first.children.object_id.should_not == @new_node_first_childs_child_id
    end

    it "should be pointing to correct parent from nested child" do
      nested_child = @new_node.children.first.children.first
      nested_child.parent.object_id.should == @new_node_first_child_id
      nested_child.parent.parent.object_id.should == @new_node_id
    end

    it "should be pointing to the correct parent for 2nd child" do
      second_child = @new_node.children.last
      second_child.parent.object_id.should == @new_node_id
    end

  end
end