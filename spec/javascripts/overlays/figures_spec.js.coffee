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

  describe "#fileUploadProcessAlways", ->
    it "appends a file upload progress section", ->
      $('#jasmine_content').html """
        <ul id="paper-figure-uploads" />
      """
      event = jasmine.createSpyObj 'event', ['target']
      data = jasmine.createSpy 'data'
      data.files = [
        { preview: $('<div id="file-preview" />')[0] }
      ]
      Tahi.overlays.figures.fileUploadProcessAlways event, data
      expect($('#paper-figure-uploads').html()).toEqual """
        <li><div id="file-preview"></div><div class="progress progress-striped active"></div></li>
      """
