beforeEach ->
  $('jasmine_content').empty()

describe "Tahi.overlays.figures", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="figures"
         data-figures-path="/path/to/figures"
         data-figures="[1, 2, 3]">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="figures"
         data-figures-path="/path/to/figures"
         data-figures="[1, 2, 3]">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.figures.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'figures', Tahi.overlays.figures.createComponent

  describe "#createComponent", ->
    it "instantiates a FiguresOverlay component", ->
      spyOn Tahi.overlays.figures.components, 'FiguresOverlay'
      Tahi.overlays.figures.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.figures.components.FiguresOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          figuresPath: '/path/to/figures'
          figures: [1, 2, 3]
      )

  describe "FiguresOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onCompletedChangedCallback = jasmine.createSpy 'onCompletedChanged'
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.figures.components.FiguresOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          figuresPath: '/path/to/figures'
          taskPath: '/path/to/task'
          taskCompleted: false
          onOverlayClosed: @onOverlayClosedCallback
          onCompletedChanged: @onCompletedChangedCallback

        @component.state =
          uploads: [
            {filename: 'in-progress.jpg', progress: 40},
            {filename: 'real-yeti.jpg', progress: 33}
          ]
          figures: [
            {
              filename: 'file-a.jpg'
              alt: 'File a'
              id: '123'
              src: '/path/to/file-a.jpg'
            },
            {
              filename: 'file-b.jpg'
              alt: 'File b'
              id: '124'
              src: '/path/to/file-b.jpg'
            }
          ]

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

      it "renders a Rails form for a new figure", ->
        form = @component.render().props.children.props.children[1].props.children[1]
        RailsForm = Tahi.overlays.components.RailsForm
        expect(form.constructor).toEqual RailsForm.componentConstructor
        expect(form.props.action).toEqual '/path/to/figures.json'
        expect(form.props.children.props.name).toEqual 'figure[attachment][]'

      it "renders a ul for upload progress", ->
        paperFigureUploads = @component.render().props.children.props.children[2]
        expect(paperFigureUploads.props.id).toEqual 'paper-figure-uploads'
        expect(paperFigureUploads.props.children.length).toEqual 2
        upload1 = paperFigureUploads.props.children[0]
        upload2 = paperFigureUploads.props.children[1]

        FigureUpload = Tahi.overlays.figures.components.FigureUpload
        expect(upload1.constructor).toEqual FigureUpload.componentConstructor
        expect(upload2.constructor).toEqual FigureUpload.componentConstructor

      it "renders the existing figures", ->
        paperFigures = @component.render().props.children.props.children[3]
        expect(paperFigures.props.id).toEqual 'paper-figures'

        expect(paperFigures.props.children.length).toEqual 2
        imageTag1 = paperFigures.props.children[0].props.children
        imageTag2 = paperFigures.props.children[1].props.children

        expect(imageTag1.props.src).toEqual '/path/to/file-a.jpg'
        expect(imageTag2.props.src).toEqual '/path/to/file-b.jpg'

    describe "#componentDidMount", ->
      beforeEach ->
        @fakeUploader = jasmine.createSpyObj 'uploader', ['on']
        spyOn($.fn, 'fileupload').and.returnValue @fakeUploader
        @html = $("""
          <div>
            <input id='jquery-file-attachment' type='file' class='js-jquery-fileupload' />
            <input id='file-attachment' type='file' />
          </div>
        """)[0]
        @component = Tahi.overlays.figures.components.FiguresOverlay()

      it "initializes jQuery filepicker", ->
        @component.componentDidMount(@html)
        expect($.fn.fileupload).toHaveBeenCalled()
        call = $.fn.fileupload.calls.mostRecent()
        expect(call.object).toEqual $('#jquery-file-attachment', @html)

      it "sets up a fileuploadprocessalways handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprocessalways', @component.fileUploadProcessAlways

      it "sets up a fileuploaddone handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploaddone', @component.fileUploadDone

      it "sets up a fileuploadprogress handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprogress', @component.fileUploadProgress

    describe "jQuery File Upload callbacks", ->
      beforeEach ->
        @component = Tahi.overlays.figures.components.FiguresOverlay()
        spyOn @component, 'setState'

        @event = jasmine.createSpyObj 'event', ['target']
        @data = jasmine.createSpy 'data'
        @previewElement = $('<div id="file-preview" />')[0]
        @data.files = [
          { preview: @previewElement, name: 'real-yeti.jpg' }
        ]

      describe "#fileUploadProcessAlways", ->
        beforeEach ->
          @component.state =
            figures: []
            uploads: [{filename: 'in-progress.jpg', progress: 40}]

        it "stores preview on window.tempStorage", ->
          expect(window.tempStorage).toBeUndefined()
          @component.fileUploadProcessAlways @event, @data
          expect(window.tempStorage['real-yeti.jpg']).toEqual @previewElement

        it "updates the upload state", ->
          @component.fileUploadProcessAlways @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploads: [
              {filename: 'in-progress.jpg', progress: 40},
              {filename: 'real-yeti.jpg', progress: 0}
            ]

      describe "#fileUploadDone", ->
        beforeEach ->
          @component.state =
            figures: [{src: '/path/to/existing.jpg', alt: 'Existing'}]
            uploads: [
              {filename: 'in-progress.jpg', progress: 40},
              {filename: 'real-yeti.jpg', progress: 99}
            ]
          @data.result = [
            { filename: 'real-yeti.jpg', alt: 'Real yeti', src: '/foo/bar/real-yeti.jpg', id: 123 }
          ]

        it "removes the preview from window.tempStorage", ->
          window.tempStorage ||= {}
          window.tempStorage['real-yeti.jpg'] = 'foo'
          @component.fileUploadDone @event, @data
          expect(window.tempStorage['real-yeti.jpg']).toBeUndefined()

        it "updates in-progress and figures state", ->
          @component.fileUploadDone @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            figures: [
              {src: '/path/to/existing.jpg', alt: 'Existing'},
              {src: '/foo/bar/real-yeti.jpg', alt: 'Real yeti'}
            ]
            uploads: [{filename: 'in-progress.jpg', progress: 40}]

      describe "#fileUploadProgress", ->
        it "updates state with the current progress", ->
          @component.state =
            figures: [{src: '/path/to/existing.jpg', alt: 'Existing'}]
            uploads: [
              {filename: 'in-progress.jpg', progress: 40},
              {filename: 'real-yeti.jpg', progress: 10}
            ]
          @data.loaded = 124.0
          @data.total = 620.0
          # 124.0 * 100 / 620.0 = 20
          @component.fileUploadProgress @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploads: [
              {filename: 'in-progress.jpg', progress: 40},
              {filename: 'real-yeti.jpg', progress: 20}
            ]

  describe "FigureUpload component", ->
    describe "#componentDidMount", ->
      it "appends the preview to preview-container", ->
        html = $('<div><div class="preview-container" /></div>')[0]
        preview = $('<div id="preview" />')[0]
        window.tempStorage ||= {}
        window.tempStorage['foo.jpg'] = preview
        component = Tahi.overlays.figures.components.FigureUpload
          filename: 'foo.jpg'
          progress: 0
        component.componentDidMount(html)
        expect($('#preview', html)[0]).toEqual preview
