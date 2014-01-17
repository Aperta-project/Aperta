beforeEach ->
  $('jasmine_content').empty()

describe "Tahi.overlays.figures", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#" id="link-1" data-card-name="figures" data-paper-title="Something" data-paper-path="/path/to/paper" data-figures-path="/path/to/figures" data-task-path="/path/to/task" data-task-completed="false">Foo</a>
      <a href="#" id="link-2" data-card-name="figures" data-paper-title="Something" data-paper-path="/path/to/paper" data-figures-path="/path/to/figures" data-task-path="/path/to/task" data-task-completed="false">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=figures", ->
      spyOn Tahi.overlays.figures, 'displayOverlay'
      Tahi.overlays.figures.init()
      $('#link-1').click()
      expect(Tahi.overlays.figures.displayOverlay).toHaveBeenCalled()

      Tahi.overlays.figures.displayOverlay.calls.reset()
      $('#link-2').click()
      expect(Tahi.overlays.figures.displayOverlay).toHaveBeenCalled()

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

  describe "FiguresOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @component = Tahi.overlays.figures.components.FiguresOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          figuresPath: '/path/to/figures'
          taskPath: '/path/to/task'
          taskCompleted: false

        @component.state =
          uploads: []
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

      it "renders an overlay footer", ->
        footer = @component.render().props.children[2]
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        expect(footer.constructor).toEqual OverlayFooter.componentConstructor
        expect(footer.props.checkboxFormAction).toEqual '/path/to/task.json'
        expect(footer.props.taskCompleted).toEqual false

      it "renders a Rails form for a new figure", ->
        form = @component.render().props.children[1].props.children[1].props.children[1]
        RailsForm = Tahi.overlays.components.RailsForm
        expect(form.constructor).toEqual RailsForm.componentConstructor
        expect(form.props.action).toEqual '/path/to/figures.json'
        expect(form.props.formContent.props.name).toEqual 'figure[attachment][]'

      it "renders a ul for upload progress", ->
        paperFigureUploads = @component.render().props.children[1].props.children[2]
        expect(paperFigureUploads.props.id).toEqual 'paper-figure-uploads'

      it "renders the existing figures", ->
        paperFigures = @component.render().props.children[1].props.children[3]
        expect(paperFigures.props.id).toEqual 'paper-figures'

        expect(paperFigures.props.children.length).toEqual 2
        imageTag1 = paperFigures.props.children[0].props.children
        imageTag2 = paperFigures.props.children[1].props.children

        expect(imageTag1.props.src).toEqual '/path/to/file-a.jpg'
        expect(imageTag2.props.src).toEqual '/path/to/file-b.jpg'

  # describe "#oldInit", ->
  #   beforeEach ->
  #     @fakeUploader = jasmine.createSpyObj 'uploader', ['on']
  #     spyOn($.fn, 'fileupload').and.returnValue @fakeUploader

  #   it "initializes jQuery filepicker", ->
  #     $('#jasmine_content').html """
  #       <input id='jquery-file-attachment' type='file' class='js-jquery-fileupload' />
  #       <input id='file-attachment' type='file' />
  #     """
  #     Tahi.overlays.figures.oldInit()
  #     expect($.fn.fileupload).toHaveBeenCalled()
  #     call = $.fn.fileupload.calls.mostRecent()
  #     expect(call.object).toEqual $('#jquery-file-attachment')

  #   it "sets up a fileuploadprocessalways handler", ->
  #     Tahi.overlays.figures.oldInit()
  #     expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprocessalways', Tahi.overlays.figures.fileUploadProcessAlways

  #   it "sets up a fileuploaddone handler", ->
  #     Tahi.overlays.figures.oldInit()
  #     expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploaddone', Tahi.overlays.figures.fileUploadDone

  #   it "sets up a fileuploadprogress handler", ->
  #     Tahi.overlays.figures.oldInit()
  #     expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprogress', Tahi.overlays.figures.fileUploadProgress

  # describe "#fileUploadProcessAlways", ->
  #   it "appends a file upload progress section", ->
  #     $('#jasmine_content').html """
  #       <ul id="paper-figure-uploads" />
  #     """
  #     event = jasmine.createSpyObj 'event', ['target']
  #     data = jasmine.createSpy 'data'
  #     data.files = [
  #       { preview: $('<div id="file-preview" />')[0], name: 'real-yeti.jpg' }
  #     ]
  #     Tahi.overlays.figures.fileUploadProcessAlways event, data
  #     expect($('#paper-figure-uploads').html()).toEqual """
  #       <li data-file-id="real-yeti.jpg"><div class="preview-container"><div id="file-preview"></div></div><div class="progress">
  #         <div class="progress-bar">
  #         </div>
  #       </div></li>
  #     """

  # describe "#fileUploadDone", ->
  #   beforeEach ->
  #     $('#jasmine_content').html """
  #       <ul id='paper-figure-uploads'>
  #         <li data-file-id="real-yeti.jpg">
  #           <div id="file-preview"></div>
  #           <div class="progress progress-striped active"></div>
  #         </li>
  #       </ul>
  #       <ul id='paper-figures'></ul>
  #     """
  #     @event = jasmine.createSpyObj 'event', ['target']
  #     @data = jasmine.createSpy 'data'
  #     @data.files = [
  #       { preview: $('<div id="file-preview" />')[0], name: 'real-yeti.jpg' }
  #     ]
  #     @data.result = [
  #       { filename: 'real-yeti.jpg', alt: 'Real yeti', src: '/foo/bar/real-yeti.jpg', id: 123 }
  #     ]

  #   it "removes the file upload progress section for this file", ->
  #     Tahi.overlays.figures.fileUploadDone @event, @data
  #     expect($('#paper-figure-uploads').html().trim()).toEqual ''

  #   it "appends an uploaded file section", ->
  #     Tahi.overlays.figures.fileUploadDone @event, @data
  #     expect($('#paper-figures').html()).toEqual """
  #       <li><img src="/foo/bar/real-yeti.jpg" alt="Real yeti"></li>
  #     """
  # describe "#fileUploadProgress", ->
  #   beforeEach ->
  #     $('#jasmine_content').html """
  #       <ul id='paper-figure-uploads'>
  #         <li data-file-id="real-yeti.jpg">
  #           <div id="file-preview"></div>
  #           <div class="progress">
  #             <div class="progress-bar">
  #             </div>
  #           </div>
  #         </li>
  #       </ul>
  #       <ul id='paper-figures'></ul>
  #     """
  #   it "updates the progress bar with the current progress", ->
  #     @event = jasmine.createSpyObj 'event', ['target']
  #     @data = jasmine.createSpy 'data'
  #     @data.files = [
  #       { preview: $('<div id="file-preview" />')[0], name: 'real-yeti.jpg' }
  #     ]
  #     @data.loaded = 124.0
  #     @data.total = 620.0

  #     progressBar = $('#paper-figure-uploads .progress .progress-bar')
  #     originalWidth = parseInt(progressBar.css('width'), 10)
  #     expectedWidth = Math.round(originalWidth * @data.loaded / @data.total)

  #     Tahi.overlays.figures.fileUploadProgress @event, @data
  #     expect(progressBar.css('width')).toEqual "#{expectedWidth}px"
