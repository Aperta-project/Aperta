beforeEach ->
  $('#jasmine_content').empty()

describe "New Card Overlay", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link-1" class="react-new-card-overlay" data-url="/some/path" data-phase-id="11" data-assignees="[1, 2, 3]"></a>
      <a href="#" id="link-2" class="react-new-card-overlay" data-url="/some/path" data-phase-id="11" data-assignees="[1, 2, 3]"></a>
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

  describe "#displayNewCardOverlay", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link-1')

    it "renders NewCardOverlay component inserting it into #new-overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      newCardOverlay = Tahi.overlays.newCard.components.NewCardOverlay({url: '/some/path', phaseId: 11, assignees: [1, 2, 3]})
      expect(React.renderComponent).toHaveBeenCalledWith(newCardOverlay, $('#new-overlay')[0], Tahi.initChosen)

    it "displays the overlay", ->
      Tahi.overlays.newCard.displayNewCardOverlay(@event)
      expect($('#new-overlay')).toBeVisible()

  describe "NewCardForm component", ->
    describe "#submit", ->
      it "submits the contents of the form", ->
        spyOn $, 'ajax'

        form = Tahi.overlays.newCard.components.NewCardForm({phaseId: '26', url: '/path/to/create/task', assignees: [[1, 'One'], [2, 'Two']]})
        React.renderComponent form, document.getElementById('jasmine_content')
        form.refs.task_title.getDOMNode().value = 'This is a title'
        form.refs.task_assignee_id.getDOMNode().value = '2'
        form.refs.task_body.getDOMNode().value = 'This is the body'

        form.submit()
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
