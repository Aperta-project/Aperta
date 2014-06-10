ETahi.JournalIndexController = Ember.ObjectController.extend
  epubCssSaveStatus: ''
  pdfCssSaveStatus: ''
  manuscriptCssSaveStatus: ''

  epubCoverUploadUrl: (->
    "/admin/journals/#{@get('model.id')}"
  ).property()

  epubCoverUploading: false

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
    epubCoverUploading: ->
      @set('epubCoverUploading', true)

    epubCoverUploaded: (data) ->
      @set('epubCoverUploading', false)
      journal = data.result.admin_journal
      @setProperties
        epubCoverUrl: journal.epub_cover_url
        epubCoverFileName: journal.epub_cover_file_name
        epubCoverUploadedAt: journal.epub_cover_uploaded_at

    saveAttr: (name) ->
      @get('model').save()
      @set("#{name}CssSaveStatus", 'Saved')

    resetSaveStatuses: ->
      @set('epubCssSaveStatus', '')
      @set('pdfCssSaveStatus', '')
      @set('manuscriptCssSaveStatus', '')
