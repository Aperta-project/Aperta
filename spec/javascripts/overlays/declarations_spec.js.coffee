beforeEach ->
  $('#jasmine_content').empty()

describe "Declarations Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link-1" data-card-name="declarations" data-paper-title="Something" data-paper-path="/path/to/paper" data-task-path="/path/to/task" data-task-completed="false" data-declarations="[]">Foo</a>
      <a href="#" id="link-2" data-card-name="declarations" data-paper-title="Something" data-paper-path="/path/to/paper" data-task-path="/path/to/task" data-task-completed="false" data-declarations="[]">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=declarations", ->
      spyOn Tahi.overlays.declarations, 'displayOverlay'
      Tahi.overlays.declarations.init()
      $('#link-1').click()
      expect(Tahi.overlays.declarations.displayOverlay).toHaveBeenCalled()

      Tahi.overlays.declarations.displayOverlay.calls.reset()
      $('#link-2').click()
      expect(Tahi.overlays.declarations.displayOverlay).toHaveBeenCalled()

  describe "#displayOverlay", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link-1')

    it "prevents event propagation", ->
      Tahi.overlays.declarations.displayOverlay(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "renders DeclarationsOverlay component inserting it into #new-overlay", ->
      Tahi.overlays.declarations.displayOverlay(@event)
      declarationsOverlay = Tahi.overlays.declarations.components.DeclarationsOverlay
        paperTitle: 'Something'
        paperPath: '/path/to/paper'
        declarations: []
        taskPath: '/path/to/task'
        taskCompleted: false
      expect(React.renderComponent).toHaveBeenCalledWith(declarationsOverlay, $('#new-overlay')[0], Tahi.initChosen)

    it "displays the overlay", ->
      Tahi.overlays.declarations.displayOverlay(@event)
      expect($('#new-overlay')).toBeVisible()

  describe "#hideOverlay", ->
    beforeEach ->
      $('#new-overlay').show()
      @event = jasmine.createSpyObj 'event', ['preventDefault']

    it "prevents default on the event", ->
      Tahi.overlays.declarations.hideOverlay(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "hides the overlay", ->
      Tahi.overlays.declarations.hideOverlay(@event)
      expect($('#new-overlay')).toBeHidden()

    it "unmounts the component", ->
      spyOn React, 'unmountComponentAtNode'
      Tahi.overlays.declarations.hideOverlay(@event)
      expect(React.unmountComponentAtNode).toHaveBeenCalledWith document.getElementById('new-overlay')

  describe "DeclarationsOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @component = Tahi.overlays.declarations.components.DeclarationsOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          declarations: []

      it "renders an overlay header", ->
        header = @component.render().props.children[0]
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        expect(header.constructor).toEqual OverlayHeader.componentConstructor

      it "renders an overlay footer", ->
        footer = @component.render().props.children[2]
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        expect(footer.constructor).toEqual OverlayFooter.componentConstructor

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.declarations.components.DeclarationsOverlay()
        html = $('<div><form><textarea /></form></div>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('textarea', html)[0]

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
