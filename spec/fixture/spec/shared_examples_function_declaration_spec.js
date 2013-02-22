describe("shared example declared in new function", function() {


  describe("group 1", function() {

    function sharedBehaviorInFunction(something) {
      describe("(shared)", function() {
        beforeEach(function() {
          $('foo').remove();
        });

        it("example 1", function() {
          expect(0).toEqual(0);
        });

        describe("group 1.1", function() {

          it("example 2", function() {
            expect(bar).toMatch(/^foo/);
          });
        });
      });
    }

    function decoyFunctionOne(){
        alert("decoy function, should be ignored");
    }
      
    describe("group 2", function() {
      sharedBehaviorInFunction(something);

      describe("source", function() {
        it("example 3", function() {
          expect(bar).toMatch('foo');
        });
      });
    });

    describe("group 3", function() {
      it("example 4", function() {
        expect($('foo').length).toEqual(0);
      });
    });
  });
});

function decoyFunctionTwo(){
    alert("decoy function, should be ignored");
}
