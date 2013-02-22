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

  class LocationFiner

    def initialize(suite)
      sort_specs suite, all_examples
    end

    def all_examples
      @all_examples ||= {}
    end

    alias :to_hash :all_examples
    alias :[] :all_examples

    def example_count
      all_examples.keys.size
    end

    def test_names
      all_examples.keys
    end

    private

    def merge_shared_specs_into_suite(suite)
      shared_examples = NodeCollector.new(suite.spec_files, :shared_behavior_declaration)

      NodeCollector.new(suite.spec_files, :function_invocation).nodes.each do |node|
        node.convert_to_shared_behavior_invocation if shared_examples[node.name]
      end

      calls_to_shared_examples = NodeCollector.new(suite.spec_files, :shared_behavior_invocation).nodes

      deep_copy_adopt(calls_to_shared_examples, shared_examples)

      shared_examples.nodes.each {|node| node.delete!}
    end

    def deep_copy_adopt(nodes, shared_examples)
      still_needs_to_adopt = NodeCollector.new(nodes, :shared_behavior_invocation, {:adoptable? => false}).nodes

      still_needs_to_adopt.each do |node|
        if shared_examples[node.name]
         node.adopt_children(shared_examples[node.name])
        else
          #If invocation is looking for a shared node that does not exist/not found, delete the invocation
          #From the list, otherwise we have an endless loop
          Announcer.warning("Could not find a shared example node with name\n#{node.name}")
          still_needs_to_adopt.delete node
        end
      end

      deep_copy_adopt still_needs_to_adopt, shared_examples unless still_needs_to_adopt.empty?
    end

    def sort_specs(suite, example_collection_hash)
      merge_shared_specs_into_suite(suite)

      all_examples = NodeCollector.new(suite.spec_files, :it).nodes
      all_examples.each do |node|
        example_info = {:name => "", :backtrace => []}
        NodeCollector.map_path_to_parent(node, example_info)

        example_collection_hash[example_info[:name].strip] = example_info[:backtrace]
      end
    end

  end
end