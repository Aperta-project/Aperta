beforeEach ->
  $('jasmine_content').empty()

describe "Tahi.overlays.figures", ->
  describe "#init", ->
    beforeEach ->
      @fakeUploader = jasmine.createSpyObj 'uploader', ['on']
      spyOn($.fn, 'fileupload').and.returnValue @fakeUploader

    it "initializes jQuery filepicker", ->
      $('#jasmine_content').html """
        <input id='jquery-file-attachment' type='file' class='js-jquery-fileupload' />
        <input id='file-attachment' type='file' />
      """
      Tahi.overlays.figures.init()
      expect($.fn.fileupload).toHaveBeenCalled()
      call = $.fn.fileupload.calls.mostRecent()
      expect(call.object).toEqual $('#jquery-file-attachment')

    it "sets up a fileuploadprocessalways handler", ->
      Tahi.overlays.figures.init()
      expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprocessalways', Tahi.overlays.figures.fileUploadProcessAlways

    it "sets up a fileuploaddone handler", ->
      Tahi.overlays.figures.init()
      expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploaddone', Tahi.overlays.figures.fileUploadDone

  describe "#fileUploadProcessAlways", ->
    it "appends a file upload progress section", ->
      $('#jasmine_content').html """
        <ul id="paper-figure-uploads" />
      """
      event = jasmine.createSpyObj 'event', ['target']
      data = jasmine.createSpy 'data'
      data.files = [
        { preview: $('<div id="file-preview" />')[0], name: 'real-yeti.jpg' }
      ]
      Tahi.overlays.figures.fileUploadProcessAlways event, data
      expect($('#paper-figure-uploads').html()).toEqual """
        <li data-file-id="real-yeti.jpg"><div id="file-preview"></div><div class="progress progress-striped active"></div></li>
      """

  describe "#fileUploadDone", ->
    beforeEach ->
      $('#jasmine_content').html """
        <ul id='paper-figure-uploads'>
          <li data-file-id="real-yeti.jpg">
            <div id="file-preview"></div>
            <div class="progress progress-striped active"></div>
          </li>
        </ul>
        <ul id='paper-figures'></ul>
      """
      @event = jasmine.createSpyObj 'event', ['target']
      @data = jasmine.createSpy 'data'
      @data.files = [
        { preview: $('<div id="file-preview" />')[0], name: 'real-yeti.jpg' }
      ]
      @data.result = [
        { filename: 'real-yeti.jpg', alt: 'Real yeti', src: '/foo/bar/real-yeti.jpg', id: 123 }
      ]

    it "removes the file upload progress section for this file", ->
      Tahi.overlays.figures.fileUploadDone @event, @data
      expect($('#paper-figure-uploads').html().trim()).toEqual ''

    it "appends an uploaded file section", ->
      Tahi.overlays.figures.fileUploadDone @event, @data
      expect($('#paper-figures').html()).toEqual """
        <li><img src="/foo/bar/real-yeti.jpg" alt="Real yeti"></li>
      """
