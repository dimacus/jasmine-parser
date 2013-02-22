Jasmine-Parser
==============

### Jasmine-Parser will read through all of the _spec.js files, creating a dependency tree of all the describe/context/it blocks. It will also try to merge any shared examples that are spread through the files, generating a full stack trace for any given test.


Problem
-------

Jasmine is a great tool for testing Javascript. However, outside of Firefox, no browser reliably supports backt races for any given test failures.

This means that, when a test fails on Internet Explorer, all you have is a full test name in the test results. This becomes complicated when a test is using shared examples from other files.

The idea is to drop in this gem into the testing gem and provide the backtrace to all of the tests in the background.


### Standard error in console when a test fails
> 1)

> RuntimeError in 'Some long test Example Name'

> Expected true to be false.

>

> ../jasmine-1.2.1/lib/jasmine/rspec_formatter.rb:41:in `declare_spec'

> ../jasmine-1.2.1/lib/jasmine/rspec_formatter.rb:72:in `report_spec'

> ../jasmine-1.2.1/lib/jasmine/rspec_formatter.rb:42:in `declare_spec'


### After jasmine-parser integration
> 1)

> RuntimeError in 'Some long test Example Name'

> Expected true to be false.

>

> ../project/spec/javascripts/test_spec.js:119:in `Name'

> ../project/spec/javascripts/test_spec.js:104:in `(shared examples)'

> ../project/spec/javascripts/test_spec.js:202:in `Example'

> ../project/spec/javascripts/test_spec.js:201:in `test'

> ../project/spec/javascripts/test_spec.js:99:in `long'

> ../project/spec/javascripts/test_spec.js:1:in `Some'

> ../jasmine-1.2.1/lib/jasmine/rspec_formatter.rb:72:in `report_spec'

> ../jasmine-1.2.1/lib/jasmine/rspec_formatter.rb:42:in `declare_spec'



Installation
------------

> gem install jasmine-parser


Using
-----

Declare a suite object

> suite = JasmineParser::JasmineSuite.new

Create a parser instance

> parser = JasmineParser::FileParser.new(suite)

Pass in an Array of files to be parsed

> parser.parse [file1, file2, file3]

After the parsing is complete, the JasmineSuite object has ability to query the test info

> suite.example_count                      #=> Total count of examples discovered

> suite.example_names                      #=> Array of all test names discovered

> suite.find_spec_location("Example name") #=> Array of file:line backtraces in order test files were called

> suite["Example name"]                    #=> An alias of "find_spec_location" method


Shared Examples
---------------

We try to automatically figure out when tests are declaring a block of shared examples, or when calling those in a later location.

Since there is no standard method for doing this, like there is in Rspec, this can get challenging. To cover as many scenarios as possible, we try to support both common ways of dealing with shared examples.

### Function declaration

Any function that is declared in the _spec.js files are treated as a possible container of shared examples. We store this function as such, and during the merging of shared examples stage, try to see if there are any references to that function. If there is, we try to find any "it" nodes inside, and build a backtrace from that.

### Storing shared methods on the window
In this article, the author recommends to store the shared examples on the window http://robots.thoughtbot.com/post/9611103221/jasmine-and-shared-examples

However, this is not the only way to solve this problem. We have inserted several commonly used shared example method names, but you can add more to the list.

Default shared example declarations: ["sharedExamples", "sharedExamplesFor"]
To add the names you use
JasmineParser::Config.shared_behavior_declarations << "Something"


Default shared example invocations: ["itShouldBehaveLike", "itBehavesLike"]
To add the names you use
JasmineParser::Config.shared_behavior_invocation << "Something"



