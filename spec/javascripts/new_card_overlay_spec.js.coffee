beforeEach ->
  $('#jasmine_content').empty()

describe "New Card Overlay", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link-1" class="react-new-card-overlay" data-url="/some/path" data-phase-id="11" data-assignees="[1, 2, 3]" data-paper-short-title="Something"></a>
      <a href="#" id="link-2" class="react-new-card-overlay" data-url="/some/path" data-phase-id="11" data-assignees="[1, 2, 3]" data-paper-short-title="Something"></a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all .react-new-card-overlay to displayNewCardOverlay", ->
      spyOn Tahi.overlays.newCard, 'displayNewCardOverlay'
      Tahi.overlays.newCard.init()
      $('#link-1').click()
      expect(Tahi.overlays.newCard.displayNewCardOverlay).toHaveBeenCalled()

      Tahi.overlays.newCard.displayNewCardOverlay.calls.reset()
      $('#link-2').click()
      expect(Tahi.overlays.newCard.displayNewCardOverlay).toHaveBeenCalled()

    describe "escape key closes the overlay", ->
      context "when the escape key is pressed", ->
        it "binds the keyup event on escape to close the overlay", ->
          $('#new-overlay').show()

          event = jQuery.Event("keyup", { which: 27 });
          $('body').trigger(event)

          expect($('#new-overlay')).toBeHidden()

      context "when any other key is pressed", ->
        it "doesn't do anything", ->
          $('#new-overlay').show()

          event = jQuery.Event("keyup", { which: 12 });
          $('body').trigger(event)

          expect($('#new-overlay')).toBeVisible()
  
  describe "#hideOverlay", ->
    beforeEach ->
      $('#new-overlay').show()
      @event = jasmine.createSpyObj 'event', ['preventDefault']

    it "prevents default on the event", ->
      Tahi.overlays.newCard.hideOverlay(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "hides the overlay", ->
      Tahi.overlays.newCard.hideOverlay(@event)
      expect($('#new-overlay')).toBeHidden()

  describe "#displayNewCardOverlay", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link-1')

    it "renders NewCardOverlay component inserting it into #new-overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      newCardOverlay = Tahi.overlays.newCard.components.NewCardOverlay({url: '/some/path', phaseId: 11, assignees: [1, 2, 3], paperShortTitle: 'Something'})
      expect(React.renderComponent).toHaveBeenCalledWith(newCardOverlay, $('#new-overlay')[0], Tahi.initChosen)

    it "displays the overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      expect($('#new-overlay')).toBeVisible()

  describe "NewCardForm component", ->
    describe "#submit", ->
      beforeEach ->
        @form = Tahi.overlays.newCard.components.NewCardForm({phaseId: '26', url: '/path/to/create/task', assignees: [[1, 'One'], [2, 'Two']]})
        React.renderComponent @form, document.getElementById('jasmine_content')

      it "closes the overlay", ->
        spyOn Tahi.overlays.newCard, 'hideOverlay'
        @form.submit()
        expect(Tahi.overlays.newCard.hideOverlay).toHaveBeenCalled()

      it "submits the contents of the form", ->
        spyOn $, 'ajax'

        @form.refs.task_title.getDOMNode().value = 'This is a title'
        @form.refs.task_assignee_id.getDOMNode().value = '2'
        @form.refs.task_body.getDOMNode().value = 'This is the body'

        @form.submit()
        expect($.ajax).toHaveBeenCalledWith
          url: '/path/to/create/task'
          method: 'POST'
          data:
            task:
              title: 'This is a title'
              body: 'This is the body'
              assignee_id: '2'
              phase_id: '26'

  describe "NewCardOverlay component", ->
    describe "#render", ->
      describe "Cancel button", ->
        it "invokes Tahi.overlays.newCard.hideOverlay on click", ->
          overlay = Tahi.overlays.newCard.components.NewCardOverlay({assignees: []})
          result = overlay.render()
          cancelButton = result.props.children[2].props.children[0].props.children
          expect(cancelButton.props.onClick).toEqual Tahi.overlays.newCard.hideOverlay

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
