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

module JasmineParser

  class NodeCollector


    def find_by_name(name)
      name_key_hash(nodes)[name]
    end
    alias :[] :find_by_name

    attr_reader :nodes
    
    def initialize(nodes, type_wanted, refine_search = {})
      @nodes = []

      drill_down(nodes, type_wanted, @nodes, refine_search)
    end

    def drill_down(nodes, type_wanted, collection, refine_search)
      nodes.each do |node|
        type_match = node.type == type_wanted
        refine_match = true
        if !refine_search.empty?
          refine_results = refine_search.keys.collect do |key|
            node.send(key.to_sym) == refine_search[key] if node.respond_to? :adoptable?
          end
          refine_match = false if refine_results.include? false
        end


        collection << node if type_match and refine_match
        drill_down node.children, type_wanted, collection, refine_search
      end
    end

    def self.map_path_to_parent(node, example_info)
      if node.parent
       example_info[:name]  = node.formatted_name + example_info[:name] if node.formatted_name
       example_info[:backtrace] << "#{node.filename}:#{node.line}:in `#{node.name}'"
       self.map_path_to_parent(node.parent, example_info)
      end
    end

    private

    def name_key_hash(collection)
      hash = {}
      collection.each do |node|
        hash[node.name] = node
      end
      hash
    end



  end

end