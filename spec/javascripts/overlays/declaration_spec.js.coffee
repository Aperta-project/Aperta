describe "Declarations Card", ->
  describe "Overlay component", ->
    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.declaration.Overlay()
        html = $('<main><form><textarea /></form></main>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('textarea', html)[0]

    describe "#componentWillReceiveProps", ->
      it "sets state.declarations to props.declarations", ->
        declarations = jasmine.createSpy 'props.declarations'
        component = Tahi.overlays.declaration.Overlay declarations: declarations
        spyOn component, 'setState'
        component.componentWillReceiveProps({declarations: declarations})
        expect(component.setState).toHaveBeenCalledWith declarations: declarations

      context "when props.declarations is falsy", ->
        it "sets state.declarations to the empty list", ->
          component = Tahi.overlays.declaration.Overlay()
          spyOn component, 'setState'
          component.componentWillReceiveProps({declarations: null})
          expect(component.setState).toHaveBeenCalledWith declarations: []

    describe "#declarations", ->
      beforeEach ->
        @component = Tahi.overlays.declaration.Overlay
          declarations: [
            {
              question: 'Question 1'
              answer: 'Answer 1'
              id: 43
            },
            {
              question: 'Question 2'
              answer: 'Answer 2'
            }
          ]
        @component.state =
          declarations: @component.props.declarations

      it "contains a div for each declaration", ->
        declarations = @component.declarations()

        label1 = declarations[0].props.children[0]
        label2 = declarations[1].props.children[0]

        textarea1 = declarations[0].props.children[1]
        textarea2 = declarations[1].props.children[1]

        expect(label1.props.children).toEqual 'Question 1'
        expect(label2.props.children).toEqual 'Question 2'

        expect(textarea1.props.defaultValue).toEqual 'Answer 1'
        expect(textarea2.props.defaultValue).toEqual 'Answer 2'

      context "when a declaration has an ID", ->
        it "includes a hidden field with declaration ID", ->
          declarationWithId = @component.declarations()[0]
          expect(declarationWithId.props.children[2].props.id).toEqual 'paper_declarations_attributes_0_id'

      context "when a declaration does not have an ID", ->
        it "does not include a hidden field with declaration ID", ->
          declarationWithoutId = @component.declarations()[1]
          expect(declarationWithoutId.props.children[2]).toEqual undefined
