ETahi.JournalIndexView = Ember.View.extend
  error: null
  epubCoverUploadedAgo: (->
    $.timeago @get('controller.model.epubCoverUploadedAt')
  ).property('controller.model.epubCoverUploadedAt')

  setupUploader: (->
    uploader = $('.js-jquery-fileupload')

    uploader.fileupload
      url: "/admin/journals/#{@controller.get('model.id')}"
      dataType: 'json'
      acceptFileTypes: /(\.|\/)(jpe?g)$/i
      method: 'PATCH'

    uploader.on 'fileuploadadd', (e, data) =>
      acceptFileTypes = /(\.|\/)(jpe?g)$/i
      if data.originalFiles[0].name is null or !acceptFileTypes.test(data.originalFiles[0].name)
        @setProperties
          error: "Sorry! '#{data.originalFiles[0]['name']}' is not of an accepted file type"
        e.preventDefault()

    uploader.on 'fileuploaddone', (e, data) =>
      @set('controller.model.epubCoverUrl', data.result.admin_journal.epub_cover_url)
      @set('controller.model.epubCoverFileName', data.result.admin_journal.epub_cover_file_name)
      @set('controller.model.epubCoverUploadedAt', data.result.admin_journal.epub_cover_uploaded_at)
  ).on('didInsertElement')
