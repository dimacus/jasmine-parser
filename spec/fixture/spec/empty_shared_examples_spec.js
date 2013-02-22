describe('node containing empty shared examples', function() {
    function sharedBehavior(someMethod) {
        var foo = 1;
    }


    describe("group that needs shared example", function() {
      sharedBehavior(someMethod);

      describe("group that does not use shared example", function() {
        it("test that does not use shared example", function() {
            expect(true).toBe(true);
        });
      });
    });

    //Stolen from http://robots.thoughtbot.com/post/9611103221/jasmine-and-shared-examples
    window.itShouldBehaveLike = function() {
        var foo = 1;
    };
})