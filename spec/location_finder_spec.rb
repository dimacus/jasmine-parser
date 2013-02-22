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


describe JasmineParser::LocationFiner do

  describe "Not shared examples" do
    before(:each) do
      @file = "spec/fixture/spec/example_spec.js"
      @suite = JasmineParser::JasmineSuite.new
      @parser = JasmineParser::FileParser.new(@suite)
      @parser.parse [@file]

      @location_finder = JasmineParser::LocationFiner.new @suite



      @test_and_location = {
        "example_spec should be here for path loading tests" => [
          "#{@file}:2:in `should be here for path loading tests'", "#{@file}:1:in `example_spec'"

        ],
        "example_spec nested_groups should contain the full name of nested example" => [
          "#{@file}:7:in `should contain the full name of nested example'", "#{@file}:6:in `nested_groups'", "#{@file}:1:in `example_spec'"
        ],
        "example_spec context group nested group in context should be here for nested context" => [

            "#{@file}:14:in `should be here for nested context'", "#{@file}:13:in `nested group in context'", "#{@file}:12:in `context group'", "#{@file}:1:in `example_spec'"
        ],

        "example with return return example_spec should have example name with return upfront" => [
          "#{@file}:23:in `should have example name with return upfront'", "#{@file}:22:in `return example_spec'", "#{@file}:21:in `example with return'"
        ],
        "example with return return example_spec return context group inside return context should be here for nested context with return" => [
          "#{@file}:29:in `should be here for nested context with return'", "#{@file}:28:in `group inside return context'", "#{@file}:27:in `return context'", "#{@file}:22:in `return example_spec'", "#{@file}:21:in `example with return'"
        ],

        "root context nested_group in context spec in context" => [
          "#{@file}:39:in `spec in context'", "#{@file}:38:in `nested_group in context'", "#{@file}:37:in `root context'" 
        ],
      }

    end

    it "should have 6 tests total" do
      @location_finder.example_count.should == 6
    end

    it "should have the correct name and line number for all examples" do
      @test_and_location.keys.each do |test_name|
        @location_finder.to_hash[test_name].should == @test_and_location[test_name]
      end
    end


  end


  describe "Shared examples" do

      context "shared in the same file" do
        before(:each) do
          @file = "spec/fixture/spec/shared_examples_spec.js"
          @suite = JasmineParser::JasmineSuite.new
          @parser = JasmineParser::FileParser.new(@suite)
          @parser.parse [@file]

          @location_finder = JasmineParser::LocationFiner.new @suite

          file = "spec/fixture/spec/shared_examples_spec.js"

          @test_and_location = {
            "node containing shared example using a window.sharedExamplesFor example 1" => [
              "#{file}:4:in `example 1'", "#{file}:13:in `shared example on window'", "#{file}:1:in `node containing shared example using a window.sharedExamplesFor'"
            ],
            "node containing shared example using a window.sharedExamplesFor example 2" => [
              "#{file}:7:in `example 2'", "#{file}:13:in `shared example on window'", "#{file}:1:in `node containing shared example using a window.sharedExamplesFor'"
            ],

            "node calling a shared behavior that is in another node group that needs shared example example 1" => [
              "#{file}:4:in `example 1'", "#{file}:21:in `shared example on window'", "#{file}:20:in `group that needs shared example'", "#{file}:18:in `node calling a shared behavior that is in another node'"
            ],
            "node calling a shared behavior that is in another node group that needs shared example example 2" => [
              "#{file}:7:in `example 2'", "#{file}:21:in `shared example on window'", "#{file}:20:in `group that needs shared example'", "#{file}:18:in `node calling a shared behavior that is in another node'"
            ],

            "node calling a shared behavior that is in another node group that needs shared example group that does not use shared example test that does not use shared example" => [
              "#{file}:24:in `test that does not use shared example'","#{file}:23:in `group that does not use shared example'", "#{file}:20:in `group that needs shared example'", "#{file}:18:in `node calling a shared behavior that is in another node'",
            ]
          }
        end

        it "should have 5 tests total" do
          @location_finder.example_count.should == 5
        end

        it "should have all backtraces correctly formatted" do
          @test_and_location.keys.each do |test_name|
            @location_finder.to_hash[test_name].should == @test_and_location[test_name]
          end
        end
      end

      context "shared between many files" do
        before(:each) do
          @files = ["spec/fixture/spec/shared_examples_spec.js", "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js"]
          @suite = JasmineParser::JasmineSuite.new
          @parser = JasmineParser::FileParser.new(@suite)
          @parser.parse @files

          @location_finder = JasmineParser::LocationFiner.new @suite

        end

        it "should be able to find the example shared between 2 files" do
          tests = {
              "call to a shared example that lives in another file example 1" => [
                  "spec/fixture/spec/shared_examples_spec.js:4:in `example 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:2:in `shared example on window'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:1:in `call to a shared example that lives in another file'"
                ],
              "call to a shared example that lives in another file example 2" => [
                  "spec/fixture/spec/shared_examples_spec.js:7:in `example 2'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:2:in `shared example on window'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:1:in `call to a shared example that lives in another file'"
                ]
          }

          tests.keys.each do |test_name|
            @location_finder.to_hash[test_name].should == tests[test_name]
          end
        end

        it "should be able to share examples which are not nested in a group" do
          tests = {
              "call to a shared example that lives in another file and not nested example 3" => [
                  "spec/fixture/spec/shared_examples_spec.js:34:in `example 3'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:6:in `shared outside any group'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:5:in `call to a shared example that lives in another file and not nested'"
                ],
              "call to a shared example that lives in another file and not nested example 4" => [
                  "spec/fixture/spec/shared_examples_spec.js:37:in `example 4'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:6:in `shared outside any group'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:5:in `call to a shared example that lives in another file and not nested'"
                ]
          }

          tests.keys.each do |test_name|
            @location_finder.to_hash[test_name].should == tests[test_name]
          end
        end

        it "should handle multiple shared examples in one group" do
           tests = {
              "multiple shared examples group 1 example 1" => [
                  "spec/fixture/spec/shared_examples_spec.js:4:in `example 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:11:in `shared example on window'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:10:in `group 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:9:in `multiple shared examples'"
                ],
              "multiple shared examples group 2 example 4" => [
                  "spec/fixture/spec/shared_examples_spec.js:37:in `example 4'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:15:in `shared outside any group'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:14:in `group 2'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:9:in `multiple shared examples'"
                ]
          }

          tests.keys.each do |test_name|
            @location_finder.to_hash[test_name].should == tests[test_name]
          end
        end

        it "should handle multiple nestings of shared examples" do
           tests = {
              "nested tests group 1 example 3" => [
                  "spec/fixture/spec/shared_examples_spec.js:34:in `example 3'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:37:in `shared outside any group'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:28:in `nested share level 2'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:22:in `nested share level 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:21:in `group 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:20:in `nested tests'"
                ],
              "nested tests group 1 example 4" => [
                  "spec/fixture/spec/shared_examples_spec.js:37:in `example 4'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:37:in `shared outside any group'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:28:in `nested share level 2'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:22:in `nested share level 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:21:in `group 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:20:in `nested tests'"
                ],
              "nested tests group 1 example 5" => [
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:30:in `example 5'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:22:in `nested share level 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:21:in `group 1'",
                  "spec/fixture/spec/call_to_shared_example_in_other_file_spec.js:20:in `nested tests'"
                ]
          }

          tests.keys.each do |test_name|
            @location_finder.to_hash[test_name].should == tests[test_name]
          end
        end
      end
  end

  describe "Shared examples in function declaration" do
    before(:each) do
      @file = "spec/fixture/spec/shared_examples_function_declaration_spec.js"
      @suite = JasmineParser::JasmineSuite.new
      @parser = JasmineParser::FileParser.new(@suite)
      @parser.parse [@file]

      @location_finder = JasmineParser::LocationFiner.new @suite
    end

    it "should have have 4 examples" do
      @location_finder.example_count.should == 4
    end

    it "should have all of the test names" do
      test_names = [
        "shared example declared in new function group 1 group 2 (shared) example 1",
        "shared example declared in new function group 1 group 2 (shared) group 1.1 example 2",
        "shared example declared in new function group 1 group 2 source example 3",
        "shared example declared in new function group 1 group 3 example 4"
      ]

      @location_finder.test_names.sort.should == test_names.sort

    end

  end
end