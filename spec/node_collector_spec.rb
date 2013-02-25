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


describe JasmineParser::NodeCollector do

  before(:each) do
    @node = JasmineParser::Node.root({:filename => "foo.txt"})
    @node.children << JasmineParser::Node.group(:filename => "foo.txt")
    @node.children.first.children << JasmineParser::Node.it(:line => 5, :name => "node 1")
    @node.children.first.children << JasmineParser::Node.it(:line => 10, :name => "node 2")
    @node.children.first.children << JasmineParser::Node.shared_behavior_invocation(:filename => "foo.txt")
  end

  it "should be able to find the it node" do
    collector = JasmineParser::NodeCollector.new([@node], :it)
    collector.nodes.size.should == 2
    collector.nodes.first.type.should == :it
  end

  it "should be able to find the :group node" do
    collector = JasmineParser::NodeCollector.new([@node], :group)
    collector.nodes.size.should == 1
    collector.nodes.first.type.should == :group
  end


  it "should be able to find the :root node" do
    collector = JasmineParser::NodeCollector.new([@node], :root)
    collector.nodes.size.should == 1
    collector.nodes.first.type.should == :root
  end

  it "should be able to refine the search" do
    collector = JasmineParser::NodeCollector.new([@node], :shared_behavior_invocation, {:adoptable? => false})
    collector.nodes.size.should == 1
    collector.nodes.first.type.should == :shared_behavior_invocation
    collector.nodes.first.adoptable?.should == false

    @node.children.first.children.last.adopted!
    collector = JasmineParser::NodeCollector.new([@node], :shared_behavior_invocation, {:adoptable? => true})
    collector.nodes.size.should == 1
    collector.nodes.first.type.should == :shared_behavior_invocation
    collector.nodes.first.adoptable?.should == true
  end

  it "should be able to search by name" do
    collector = JasmineParser::NodeCollector.new([@node], :it)
    collector["node 1"].line.should == 5
    collector["node 2"].line.should == 10
  end

  it "should return nil for node not found" do
    collector = JasmineParser::NodeCollector.new([@node], :it)
    collector["asfdsf"].nil?.should == true
  end

end