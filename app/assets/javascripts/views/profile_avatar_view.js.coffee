ETahi.ProfileAvatarView = Ember.View.extend
  templateName: 'user/profile_avatar'

  mouseEnter: (e) ->
    $('#profile-avatar-hover').show()

  mouseLeave: (e) ->
    $('#profile-avatar-hover').hide()


  setupUploader: (->
    uploader = $('.js-jquery-fileupload')

    uploader.fileupload
      url: "/users/#{@get('controller.model.id')}"
      dataType: 'json'
      method: 'PATCH'
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|tiff)$/i

    uploader.on 'fileuploadalways', (e, data) =>
      $('#profile-avatar-hover').hide()

    uploader.on 'fileuploaddone', (e, data) =>
      $('#profile-avatar img').attr('src', data.result.image_url)
      $('#profile-avatar-spinner').hide()

    uploader.on 'fileuploadprogress', (e, data) =>
      spinnerDiv = document.getElementById('profile-avatar-spinner')
      @spinner ||= new Spinner({color: "#fff"}).spin(spinnerDiv)
      $(spinnerDiv).show()

  ).on('didInsertElement')

