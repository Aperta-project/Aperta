beforeEach ->
  $('#jasmine_content').empty()

describe "Assign Reviewers Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-admin-id="1"
         data-admins='[[1, "one"], [2, "two"], [3, "three"]]'
         data-card-name="paper-admin">Foo</a>
      <a href="#"
         id="link2"
         data-admin-id="1"
         data-admins='[[1, "one"], [2, "two"], [3, "three"]]'
         data-card-name="paper-admin">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.paperAdmin.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'paper-admin', Tahi.overlays.paperAdmin.createComponent

  describe "#createComponent", ->
    it "instantiates a PaperAdminOverlay component", ->
      spyOn Tahi.overlays.paperAdmin.components, 'PaperAdminOverlay'
      Tahi.overlays.paperAdmin.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.paperAdmin.components.PaperAdminOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          adminId: 1
          admins: [[1, 'one'], [2, 'two'], [3, 'three']]
      )

  describe "PaperAdminOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.paperAdmin.components.PaperAdminOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback
          adminId: 1
          admins: [[1, 'one'], [2, 'two'], [3, 'three']]

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.paperAdmin.components.PaperAdminOverlay()
        html = $('<div><main><form><select /></form></main></div>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]
