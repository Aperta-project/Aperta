beforeEach ->
  $('#jasmine_content').empty()

describe "Assign Reviewers Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-reviewer-ids="[1,2]"
         data-reviewers='[[1, "one"], [2, "two"], [3, "three"]]'
         data-card-name="paper-reviewer">Foo</a>
      <a href="#"
         id="link2"
         data-reviewer-ids="[1,2]"
         data-reviewers='[[1, "one"], [2, "two"], [3, "three"]]'
         data-card-name="paper-reviewer">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.assignReviewers.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'paper-reviewer', Tahi.overlays.assignReviewers.createComponent

  describe "#createComponent", ->
    it "instantiates a AssignReviewersOverlay component", ->
      spyOn Tahi.overlays.assignReviewers.components, 'AssignReviewersOverlay'
      Tahi.overlays.assignReviewers.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.assignReviewers.components.AssignReviewersOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          reviewerIds: [1, 2]
          reviewers: [[1, 'one'], [2, 'two'], [3, 'three']]
      )

  describe "AssignReviewersOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.assignReviewers.components.AssignReviewersOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback
          reviewerIds: [1, 2]
          reviewers: [[1, 'one'], [2, 'two'], [3, 'three']]

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.assignReviewers.components.AssignReviewersOverlay()
        html = $('<div><main><form><select /></form></main></div>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]
