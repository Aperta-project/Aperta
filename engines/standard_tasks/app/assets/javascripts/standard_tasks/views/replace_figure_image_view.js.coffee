ETahi.ReplaceFigureImageView = Ember.View.extend
  templateName: 'standard_tasks/overlays/figure/replace_image'
  tagName: 'button'
  classNames: "primary-button white-button replace fileinput-button".w()

  spinnerOpts: (->
    lines: 7 # The number of lines to draw
    length: 0 # The length of each line
    width: 7 # The line thickness
    radius: 7 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: '#fff' # #rgb or #rrggbb or array of colors
    speed: 1.3 # Rounds per second
    trail: 68 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: 'spinner' # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: '50%'
    left: '50%'
  ).property()


  setupUploader: (->
    uploader = @$().find('.js-jquery-fileupload')

    uploader.fileupload
      url: "/figures/#{@get('controller.figure.id')}"
      dataType: 'json'
      method: 'PATCH'
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|eps|tif?f)$/i

    uploader.on 'fileuploadprogress', (e, data) =>
      @spinnerDiv = @$().closest('.figure-thumbnail-image').find('.replace-spinner')[0]
      @spinner ||= new Spinner(@get('spinnerOpts')).spin(@spinnerDiv)
      $(@spinnerDiv).show()

    uploader.on 'fileuploaddone', (e, data) =>
      store = @get('controller.figure.store')
      store.pushPayload 'figure', data.result
      $(@spinnerDiv).hide()
  ).on('didInsertElement')


