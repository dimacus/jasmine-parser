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
require 'shared_examples_for_end_to_end'

describe "parsing well formatted, single file" do
  before(:each) do
    @filename = "spec/fixture/spec/example_spec.js"
    @suite = JasmineParser::JasmineSuite.new
    @parser = JasmineParser::FileParser.new(@suite)
    @parser.parse [@filename]
    @file_count = 1
  end

  it_behaves_like "In depth tests of nodes"

end


describe "parsing poorly formatted, single file" do
  before(:each) do
    @filename = "spec/fixture/spec/example_spec_with_strange_spacing.js"
    @suite = JasmineParser::JasmineSuite.new
    @parser = JasmineParser::FileParser.new(@suite)
    @parser.parse [@filename]
    @file_count = 1
  end

  it_behaves_like "In depth tests of nodes"

end

describe "multi file parsing" do
  before(:each) do
    @file_1 = "spec/fixture/spec/example_spec.js"
    @file_2 = "spec/fixture/spec/small_file.js"
    @suite = JasmineParser::JasmineSuite.new
    @parser = JasmineParser::FileParser.new(@suite)
    @parser.parse [@file_1,
                   @file_2]
    @file_count = 2
  end

  describe "individual file tests for first file" do
    before(:each) do
      @filename = @file_1
    end

    it_behaves_like "In depth tests of nodes"
  end

  describe "individual file tests for second file" do
    describe "root node" do
      before(:each) do
        @node = @suite.spec_files.last

        @node_name           = ""
        @node_type           = :root
        @node_line     = 0
        @node_final_line     = 5
        @node_parent         = nil
        @node_filename       = @file_2
        @node_children_count = 1

      end

      it_behaves_like "node info tests"
    end
  end


end