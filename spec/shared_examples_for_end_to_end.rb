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

shared_examples "node info tests" do
  
    it "should contain correct node name" do
      @node.name.should == @node_name
    end

    it "should correct type" do
      @node.type.should == @node_type
    end

    it "should start on correct line" do
      @node.line.should == @node_line
    end

    it "should not have correct parent" do
      @node.parent.should == @node_parent
    end

    it "should have correct filename" do
      @node.filename.should == @node_filename
    end

    it "should have correct children nodes" do
      @node.children.size.should == @node_children_count
    end

end

shared_examples "node children tests" do
  it "should have correct name for children nodes" do

    @node.children.each_with_index do |child, index|
      child.name.should == @children[index]
    end

  end
end

shared_examples "In depth tests of nodes" do
  it "should suite should contain only 1 spec_file" do
    @suite.spec_files.size.should == @file_count
  end

  describe "root node" do
    before(:each) do
      @node = @suite.spec_files.first

      @node_name           = ""
      @node_type           = :root
      @node_line           = 0
      @node_parent         = nil
      @node_filename       = @filename
      @node_children_count = 3

    end

    it_behaves_like "node info tests"



    describe "example_spec node" do
      before(:each) do
        @node = @suite.spec_files.first.children.first
        @node_name           = "example_spec"
        @node_type           = :group
        @node_line           = 1
        @node_parent         = @suite.spec_files.first
        @node_filename       = @filename
        @node_children_count = 3

        @children = ["should be here for path loading tests", "nested_groups", "context group"]
      end

      it_behaves_like "node info tests"
      it_behaves_like "node children tests"

        describe "it node" do
          before(:each) do
            @node = @suite.spec_files.first.children.first.children.first
            @node_name           = "should be here for path loading tests"
            @node_type           = :it
            @node_line           = 2
            @node_parent         = @suite.spec_files.first.children.first
            @node_filename       = @filename
            @node_children_count = 1
          end
          it_behaves_like "node info tests"
        end

        describe "nested_group" do
          before(:each) do
            @node = @suite.spec_files.first.children.first.children[1]
            @node_name           = "nested_groups"
            @node_type           = :group
            @node_line           = 6
            @node_parent         = @suite.spec_files.first.children.first
            @node_filename       = @filename
            @node_children_count = 1

            @children = ["should contain the full name of nested example"]
          end
          it_behaves_like "node info tests"
          it_behaves_like "node children tests"
        end

        describe "context group" do
          before(:each) do
            @node = @suite.spec_files.first.children.first.children[2]
            @node_name           = "context group"
            @node_type           = :group
            @node_line           = 12
            @node_parent         = @suite.spec_files.first.children.first
            @node_filename       = @filename
            @node_children_count = 1

            @children = ["nested group in context"]
          end
          it_behaves_like "node info tests"
          it_behaves_like "node children tests"
        end
    end

    describe "example with return" do
      before(:each) do
        @node = @suite.spec_files.first.children[1]
        @node_name           = "example with return"
        @node_type           = :group
        @node_line           = 21
        @node_parent         = @suite.spec_files.first
        @node_filename       = @filename
        @node_children_count = 1

        @children = ["return example_spec"]
      end

      it_behaves_like "node info tests"
      it_behaves_like "node children tests"

      describe "return group" do
        before(:each) do
          @node = @suite.spec_files.first.children[1].children.first
          @node_name           = "return example_spec"
          @node_type           = :group
          @node_line           = 22
          @node_parent         = @suite.spec_files.first.children[1]
          @node_filename       = @filename
          @node_children_count = 2

          @children = ["should have example name with return upfront", "return context"]
        end

        it_behaves_like "node info tests"
        it_behaves_like "node children tests"

        describe "return it" do
          before(:each) do
            @node = @suite.spec_files.first.children[1].children.first.children.first
            @node_name           = "should have example name with return upfront"
            @node_type           = :it
            @node_line           = 23
            @node_parent         = @suite.spec_files.first.children[1].children.first
            @node_filename       = @filename
            @node_children_count = 1
          end

          it_behaves_like "node info tests"
        end

        describe "return context" do
          before(:each) do
            @node = @suite.spec_files.first.children[1].children.first.children.last
            @node_name           = "return context"
            @node_type           = :group
            @node_line           = 27
            @node_parent         = @suite.spec_files.first.children[1].children.first
            @node_filename       = @filename
            @node_children_count = 1

            @children = ["group inside return context"]
          end

          it_behaves_like "node info tests"
          it_behaves_like "node children tests"
        end

      end
    end

    describe "root context" do
      before(:each) do
        @node = @suite.spec_files.first.children.last
        @node_name           = "root context"
        @node_type           = :group
        @node_line           = 37
        @node_parent         = @suite.spec_files.first
        @node_filename       = @filename
        @node_children_count = 1

        @children = ["nested_group in context"]
      end

      it_behaves_like "node info tests"
      it_behaves_like "node children tests"

    end

  end
  
end