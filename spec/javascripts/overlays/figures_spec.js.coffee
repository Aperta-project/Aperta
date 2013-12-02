beforeEach ->
  $('jasmine_content').empty()

describe "Tahi.overlays.figures", ->
  describe "#init", ->
    it "initializes jQuery filepicker", ->
      $('#jasmine_content').html """
        <input id='jquery-file-attachment' type='file' class='js-jquery-fileupload' />
        <input id='file-attachment' type='file' />
      """
      spyOn $.fn, 'fileupload'
      Tahi.overlays.figures.init()
      expect($.fn.fileupload).toHaveBeenCalled()
      call = $.fn.fileupload.calls.mostRecent()
      expect(call.object).toEqual $('#jquery-file-attachment')
