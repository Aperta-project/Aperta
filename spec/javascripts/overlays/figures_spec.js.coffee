beforeEach ->
  $('jasmine_content').empty()

describe "Tahi.overlays.figures", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link1" data-card-name="figures" data-paper-title="Something" data-paper-path="/path/to/paper" data-figures-path="/path/to/figures" data-task-path="/path/to/task">Foo</a>
      <a href="#" id="link2" data-card-name="figures" data-paper-title="Something" data-paper-path="/path/to/paper" data-figures-path="/path/to/figures" data-task-path="/path/to/task">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=figures", ->
      spyOn Tahi.overlays.figures, 'displayOverlay'
      Tahi.overlays.figures.init()
      $('#link1').click()
      expect(Tahi.overlays.figures.displayOverlay).toHaveBeenCalled()

      Tahi.overlays.figures.displayOverlay.calls.reset()
      $('#link2').click()
      expect(Tahi.overlays.figures.displayOverlay).toHaveBeenCalled()

  describe "#displayOverlay", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')
      @overlay = jasmine.createSpy 'FiguresOverlay'
      spyOn(Tahi.overlays.figures.components, 'FiguresOverlay').and.returnValue @overlay

    it "prevents event propagation", ->
      Tahi.overlays.figures.displayOverlay(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "instantiates a FiguresOverlay component", ->
      Tahi.overlays.figures.displayOverlay(@event)
      expect(Tahi.overlays.figures.components.FiguresOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          figuresPath: '/path/to/figures'
          taskPath: '/path/to/task'
          onCompletedChanged: Tahi.overlays.figures.handleCompletedChanged
      )

    it "renders FiguresOverlay component inserting it into #new-overlay", ->
      Tahi.overlays.figures.displayOverlay(@event)
      expect(React.renderComponent).toHaveBeenCalledWith(@overlay, $('#new-overlay')[0], Tahi.initChosen)

    context "when the link does not have the completed class", ->
      it "instantiates the component with taskCompleted false", ->
        $('#link1, #link2').removeClass 'completed'
        Tahi.overlays.figures.displayOverlay(@event)
        expect(Tahi.overlays.figures.components.FiguresOverlay).toHaveBeenCalledWith(
          jasmine.objectContaining taskCompleted: false
        )

    context "when the link has the completed class", ->
      it "instantiates the component with taskCompleted true", ->
        $('#link1, #link2').addClass 'completed'
        Tahi.overlays.figures.displayOverlay(@event)
        expect(Tahi.overlays.figures.components.FiguresOverlay).toHaveBeenCalledWith(
          jasmine.objectContaining taskCompleted: true
        )

  describe "#hideOverlay", ->
    beforeEach ->
      $('#new-overlay').show()
      @event = jasmine.createSpyObj 'event', ['preventDefault']

    it "prevents default on the event", ->
      Tahi.overlays.figures.hideOverlay(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "hides the overlay", ->
      Tahi.overlays.figures.hideOverlay(@event)
      expect($('#new-overlay')).toBeHidden()

    it "unmounts the component", ->
      spyOn React, 'unmountComponentAtNode'
      Tahi.overlays.figures.hideOverlay(@event)
      expect(React.unmountComponentAtNode).toHaveBeenCalledWith document.getElementById('new-overlay')

  describe "#handleCompletedChanged", ->
    context "when the task has been completed", ->
      it "sets the completed class", ->
        $('#link1, #link2').removeClass 'completed'
        event = jasmine.createSpy 'event'
        data =
          completed: true
          id: 123

        Tahi.overlays.figures.init()
        Tahi.overlays.figures.handleCompletedChanged event, data
        expect($('#link1')).toHaveClass 'completed'
        expect($('#link2')).toHaveClass 'completed'

    context "when the task has not been completed", ->
      it "clears the completed class", ->
        $('#link1, #link2').addClass 'completed'
        event = jasmine.createSpy 'event'
        data =
          completed: false
          id: 123

        Tahi.overlays.figures.init()
        Tahi.overlays.figures.handleCompletedChanged event, data
        expect($('#link1')).not.toHaveClass 'completed'
        expect($('#link2')).not.toHaveClass 'completed'

  describe "FiguresOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onCompletedChangedCallback = jasmine.createSpy 'onCompletedChanged'
        @component = Tahi.overlays.figures.components.FiguresOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          figuresPath: '/path/to/figures'
          taskPath: '/path/to/task'
          taskCompleted: false
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

      it "renders an overlay header", ->
        header = @component.render().props.children[0]
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        expect(header.constructor).toEqual OverlayHeader.componentConstructor
        expect(header.props.paperTitle).toEqual 'Something'
        expect(header.props.paperPath).toEqual '/path/to/paper'

      it "renders an overlay footer, passing it an onCompletedChanged callback", ->
        footer = @component.render().props.children[2]
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        expect(footer.constructor).toEqual OverlayFooter.componentConstructor
        expect(footer.props.checkboxFormAction).toEqual '/path/to/task.json'
        expect(footer.props.taskCompleted).toEqual false
        expect(footer.props.onCompletedChanged).toEqual @onCompletedChangedCallback

      it "renders a Rails form for a new figure", ->
        form = @component.render().props.children[1].props.children[1].props.children[1]
        RailsForm = Tahi.overlays.components.RailsForm
        expect(form.constructor).toEqual RailsForm.componentConstructor
        expect(form.props.action).toEqual '/path/to/figures.json'
        expect(form.props.formContent.props.name).toEqual 'figure[attachment][]'

      it "renders a ul for upload progress", ->
        paperFigureUploads = @component.render().props.children[1].props.children[2]
        expect(paperFigureUploads.props.id).toEqual 'paper-figure-uploads'
        expect(paperFigureUploads.props.children.length).toEqual 2
        upload1 = paperFigureUploads.props.children[0]
        upload2 = paperFigureUploads.props.children[1]

        FigureUpload = Tahi.overlays.figures.components.FigureUpload
        expect(upload1.constructor).toEqual FigureUpload.componentConstructor
        expect(upload2.constructor).toEqual FigureUpload.componentConstructor

      it "renders the existing figures", ->
        paperFigures = @component.render().props.children[1].props.children[3]
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
