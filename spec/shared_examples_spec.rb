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

require 'spec_helper'

describe JasmineParser::FileParser do
  before(:each) do
    @suite = JasmineParser::JasmineSuite.new
    @parser = JasmineParser::FileParser.new(@suite)
    @parser.parse ["spec/fixture/spec/shared_examples_spec.js"]
  end


  describe "globally shared behavior" do
    before(:each) do
      @invocation_node  = @suite.spec_files.first.children.first.children.last
    end

    describe "declaration" do

      it "should delete the declaration node" do
        @suite.spec_files.first.children.first.children.first.type.should_not == :shared_behavior_declaration
        @suite.spec_files.first.children.first.children.size.should == 1
      end

    end

    describe "invocation" do
      it "should have the correct type" do
        @invocation_node.type.should == :shared_behavior_invocation
      end

      it "should be named correctly" do
        @invocation_node.name.should == "shared example on window"
      end

      it "should have 2 children" do
        @invocation_node.children.size.should == 2
      end
    end

  end

end