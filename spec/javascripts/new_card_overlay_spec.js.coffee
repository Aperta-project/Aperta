beforeEach ->
  $('#jasmine_content').empty()

describe "New Card Overlay", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link-1" class="react-choose-card-type-overlay" data-url="/some/path" data-phase_id="11" data-assignees="[1, 2, 3]" data-paper_title="Something"></a>
      <a href="#" id="link-2" class="react-choose-card-type-overlay" data-url="/some/path" data-phase_id="11" data-assignees="[1, 2, 3]" data-paper_title="Something"></a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all .react-choose-card-type-overlay to displayNewCardOverlay", ->
      spyOn Tahi.overlays.newCard, 'displayNewCardOverlay'
      Tahi.overlays.newCard.init()
      $('#link-1').click()
      expect(Tahi.overlays.newCard.displayNewCardOverlay).toHaveBeenCalled()

      Tahi.overlays.newCard.displayNewCardOverlay.calls.reset()
      $('#link-2').click()
      expect(Tahi.overlays.newCard.displayNewCardOverlay).toHaveBeenCalled()

  describe "#displayNewCardOverlay", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link-1')

    it "renders NewCardOverlay component inserting it into #overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      newCardOverlay = Tahi.overlays.newCard.components.NewCardOverlay({url: '/some/path', phaseId: 11, assignees: [1, 2, 3], paperShortTitle: 'Something'})
      expect(React.renderComponent).toHaveBeenCalledWith(newCardOverlay, $('#overlay')[0])

    it "displays the overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      expect($('#overlay')).toBeVisible()

  describe "NewCardForm component", ->
    describe "#submit", ->
      beforeEach ->
        @form = Tahi.overlays.newCard.components.NewCardForm({phaseId: '26', url: '/path/to/create/task', assignees: [[1, 'One'], [2, 'Two']]})
        React.renderComponent @form, document.getElementById('jasmine_content')

      it "closes the overlay", ->
        spyOn Tahi.overlay, 'hide'
        @form.submit()
        expect(Tahi.overlay.hide).toHaveBeenCalled()

      it "submits the contents of the form", ->
        spyOn $, 'ajax'

        @form.refs.task_title.getDOMNode().value = 'This is a title'
        @form.refs.task_assignee_id.getDOMNode().value = '2'
        @form.refs.task_body.getDOMNode().value = 'This is the body'

        @form.submit()
        expect($.ajax).toHaveBeenCalledWith
          url: '/path/to/create/task'
          method: 'POST'
          success: jasmine.any(Function)
          data:
            task:
              title: 'This is a title'
              body: 'This is the body'
              assignee_id: '2'
              phase_id: '26'

      it "uses Turbolinks to reload the page on success", ->
        spyOn $, 'ajax'

        @form.refs.task_title.getDOMNode().value = 'This is a title'
        @form.refs.task_assignee_id.getDOMNode().value = '2'
        @form.refs.task_body.getDOMNode().value = 'This is the body'

        @form.submit()
        spyOn Turbolinks, 'visit'
        $.ajax.calls.mostRecent().args[0].success()
        expect(Turbolinks.visit).toHaveBeenCalledWith window.location

  describe "NewCardOverlay component", ->
    describe "#render", ->
      describe "Cancel button", ->
        it "invokes Tahi.overlay.hideOverlay on click", ->
          overlay = Tahi.overlays.newCard.components.NewCardOverlay({assignees: []})
          result = overlay.render()
          cancelButton = result.props.children[2].props.children[0].props.children
          expect(cancelButton.props.onClick).toEqual Tahi.overlay.hide

      describe "Create card button", ->
        it "invokes submitForm on click", ->
          overlay = Tahi.overlays.newCard.components.NewCardOverlay({assignees: []})
          result = overlay.render()
          createCardButton = result.props.children[2].props.children[1]
          expect(createCardButton.props.onClick).toEqual overlay.submitForm

        it "assigns form", ->
          overlay = Tahi.overlays.newCard.components.NewCardOverlay({assignees: []})
          result = overlay.render()
          expect(overlay.form).toBeDefined()

    describe "#submitForm", ->
      beforeEach ->
        @overlay = Tahi.overlays.newCard.components.NewCardOverlay()
        @overlay.form = jasmine.createSpyObj 'form', ['submit']
        @event = jasmine.createSpyObj 'event', ['preventDefault']

      it "prevents default on the event", ->
        @overlay.submitForm(@event)
        expect(@event.preventDefault).toHaveBeenCalled()

      it "submits the form", ->
        @overlay.submitForm(@event)
        expect(@overlay.form.submit).toHaveBeenCalled()
