describe("call to a shared example that lives in another file", function(){
    itBehavesLike('shared example on window');
})

describe("call to a shared example that lives in another file and not nested", function(){
    itBehavesLike('shared outside any group');
})

describe("multiple shared examples", function(){
    context("group 1", function(){
        itBehavesLike('shared example on window');
    })

    context("group 2", function(){
        itBehavesLike('shared outside any group');    
    })

})

describe("nested tests", function(){
    context("group 1", function(){
      itBehavesLike("nested share level 1")  
    })
})


sharedExamplesFor("nested share level 1", function() {
    itBehavesLike('nested share level 2');

    it("example 5", function(){
        expect(true).toBe(true);
    })

});

sharedExamplesFor("nested share level 2", function() {
    itBehavesLike('shared outside any group');
});
