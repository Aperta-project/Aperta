ETahi.JournalIndexController = Ember.ObjectController.extend
  epubCssSaveStatus: ''
  pdfCssSaveStatus: ''

  journalUrl: (->
    "/admin/journals/#{@get('model.id')}"
  ).property('model.id')

  epubCoverUploadedAgo: (->
    uploadTime = @get('epubCoverUploadedAt')
    if uploadTime
      $.timeago @get('epubCoverUploadedAt')
    else
      null
  ).property('epubCoverUploadedAt')

  actions:
    coverUploaded: (data) ->
      journal = data.result.admin_journal
      @setProperties
        epubCoverUrl: journal.epub_cover_url
        epubCoverFileName: journal.epub_cover_file_name
        epubCoverUploadedAt: journal.epub_cover_uploaded_at

    saveEpubCss: ->
      @get('model').save()
      @set('epubCssSaveStatus', 'Saved')

    savePdfCss: ->
      @get('model').save()
      @set('pdfCssSaveStatus', 'Saved')
