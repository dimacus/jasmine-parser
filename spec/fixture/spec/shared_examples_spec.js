describe("node containing shared example using a window.sharedExamplesFor", function(){

     sharedExamplesFor("shared example on window", function() {
        it("example 1", function() {
           expect(true).toBe(true);
        });
        it("example 2", function() {
           expect(true).toBe(true);
        });
     });


    itBehavesLike('shared example on window');

})


describe('node calling a shared behavior that is in another node', function() {

    describe("group that needs shared example", function() {
      itBehavesLike('shared example on window');

      describe("group that does not use shared example", function() {
        it("test that does not use shared example", function() {
            expect(true).toBe(true);
        });
      });
    });
});



sharedExamplesFor("shared outside any group", function() {
   it("example 3", function() {
      expect(true).toBe(true);
   });
   it("example 4", function() {
      expect(true).toBe(true);
   });
});



