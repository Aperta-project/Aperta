ETahi.JournalIndexController = Ember.ObjectController.extend
  journalUrl: (->
    url: "/admin/journals/#{@get('id')}"
  ).property('id')

  epubCoverUploadedAgo: (->
    $.timeago @get('epubCoverUploadedAt')
  ).property('epubCoverUploadedAt')

  actions:
    coverUploaded: ({result: journal}) =>
      @setProperties
        epubCoverUrl: journal.epub_cover_url
        epubCoverFileName: journal.epub_cover_file_name
        epubCoverUploadedAt: journal.epub_cover_uploaded_at
