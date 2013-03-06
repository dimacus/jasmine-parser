// Declare shared example in variable

var sharedBehaviorInMethod;

sharedBehaviorInMethod = function(some_var) {
    describe("shared group in variable", function() {
        return it("example 1", function() {
          return expect(true).toBe(true);
        });
    });
};

window.sharedBehaviorOnWindow = {};

sharedBehaviorOnWindow.sharedExample = function(){

 describe('shared group on window', function() {
        it('example 2', function() {
          return expect(true).toBe(true);
        });
        return it('example 3', function() {
          return expect(true).toBe(true);
        });
      });

};
