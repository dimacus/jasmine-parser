describe("example_spec", function() {
  it("should be here for path loading tests", function() {
    expect(true).toBe(true);
  })

  describe("nested_groups", function() {
    it("should contain the full name of nested example", function(){
	    expect(true).toBe(true);
	  })

  context('context group', function(){
    describe('nested group in context', function(){
      it("should be here for nested context", function(){
        expect(true).toBe(true);
      })
    })
  })
})





//no closing }) on line 10