describe "Tahi.overlays.standardsFigure", ->
  describe "FigureOverlay component", ->
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
        @component = Tahi.overlays.standardsFigure.Overlay()
        spyOn(@component, 'getDOMNode').and.returnValue($(@html)[0])

      it "initializes jQuery filepicker", ->
        @component.componentDidMount()
        expect($.fn.fileupload).toHaveBeenCalled()
        call = $.fn.fileupload.calls.mostRecent()
        expect(call.object).toEqual $('#jquery-file-attachment', @html)

      it "sets up a fileuploadprocessalways handler", ->
        @component.componentDidMount()
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprocessalways', @component.fileUploadProcessAlways

      it "sets up a fileuploaddone handler", ->
        @component.componentDidMount()
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploaddone', @component.fileUploadDone

      it "sets up a fileuploadprogress handler", ->
        @component.componentDidMount()
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprogress', @component.fileUploadProgress

    describe "jQuery File Upload callbacks", ->
      beforeEach ->
        @component = Tahi.overlays.standardsFigure.Overlay()
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
        component = Tahi.overlays.standardsFigure.FigureUpload
          filename: 'foo.jpg'
          progress: 0
        spyOn(component, 'getDOMNode').and.returnValue($(html)[0])
        component.componentDidMount()
        expect($('#preview', html)[0]).toEqual preview
