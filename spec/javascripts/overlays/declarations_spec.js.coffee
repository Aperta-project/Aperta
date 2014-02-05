beforeEach ->
  $('#jasmine_content').empty()

describe "Declarations Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="declaration"
         data-declarations="[1, 2]">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="declaration"
         data-declarations="[1, 2]">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.declarations.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'declaration', Tahi.overlays.declarations.createComponent

  describe "#createComponent", ->
    it "instantiates a DeclarationsOverlay component", ->
      spyOn Tahi.overlays.declarations.components, 'DeclarationsOverlay'
      Tahi.overlays.declarations.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.declarations.components.DeclarationsOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          declarations: [1, 2]
      )

  describe "DeclarationsOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.declarations.components.DeclarationsOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback
          declarations: []

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.declarations.components.DeclarationsOverlay()
        html = $('<div><main><form><textarea /></form></main></div>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('textarea', html)[0]

    describe "#componentWillUnmount", ->
      it "updates the declarations data attribute on all cards", ->
        $('#jasmine_content').html """
          <div id="one" data-card-name='declaration' data-declarations='[1, 2, 3]' />
          <div id="two" data-card-name='declaration' data-declarations='[1, 2, 3]' />
        """

        component = Tahi.overlays.declarations.components.DeclarationsOverlay
          declarations: [
            {
              question: 'Question 1'
              answer: 'Answer 1'
              id: 43
            },
            {
              question: 'Question 2'
              answer: 'Answer 2'
              id: 44
            }
          ]

        component.refs =
          declaration_question_0:
            props:
              children:
                'Question 1'
          declaration_question_1:
            props:
              children:
                'Question 2'
          declaration_answer_0:
            getDOMNode: ->
              value: 'Answer 1'
          declaration_answer_1:
            getDOMNode: ->
              value: 'New answer'

        component.componentWillUnmount()

        expectedDeclarations = [
          {
            question: 'Question 1'
            answer: 'Answer 1'
            id: 43
          },
          {
            question: 'Question 2'
            answer: 'New answer'
            id: 44
          }
        ]

        expect($('#one').data('declarations')).toEqual expectedDeclarations
        expect($('#two').data('declarations')).toEqual expectedDeclarations

    describe "#declarations", ->
      beforeEach ->
        @component = Tahi.overlays.declarations.components.DeclarationsOverlay
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
