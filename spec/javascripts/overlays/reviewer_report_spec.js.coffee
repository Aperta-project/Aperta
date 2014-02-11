beforeEach ->
  $('#jasmine_content').empty()

describe "Reviewer Report Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="reviewer-report">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="reviewer-report">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.reviewerReport.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'reviewer-report'

  describe "#createComponent", ->
    it "instantiates a ReviewerReportOverlay component", ->
      spyOn Tahi.overlays.reviewerReport.components, 'ReviewerReportOverlay'
      Tahi.overlays.reviewerReport.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.reviewerReport.components.ReviewerReportOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
      )

  describe "ReviewerReportOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @component = Tahi.overlays.reviewerReport.components.ReviewerReportOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.reviewerReport.components.ReviewerReportOverlay()
        html = $('<div><main><form><textarea /></form></main></div>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('textarea', html)[0]
