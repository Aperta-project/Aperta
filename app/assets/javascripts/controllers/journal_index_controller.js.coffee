ETahi.JournalIndexController = Ember.ObjectController.extend
  epubCssSaveStatus: ''
  pdfCssSaveStatus: ''
  manuscriptCssSaveStatus: ''
  doiEditState: false

  epubCoverUploadUrl: (->
    "/admin/journals/#{@get('model.id')}/upload_epub_cover"
  ).property()

  adminJournalUsers: null

  epubCoverUploading: false

  resetSearch: ->
    @set 'adminJournalUsers', null
    @set 'placeholderText', null

  logo: (->
    logoUrl = @get("logoUrl")
    if /no-journal-image/.test logoUrl
      false
    else
      logoUrl
  ).property('logoUrl')

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

  formattedDOI: (->
    if @get 'doiInvalid'
      ''
    else
      publisher = @get('doiPublisherPrefix')
      journal   = @get('doiJournalPrefix')
      start     = @get('doiStartNumber')

      "#{publisher}/#{journal}#{if Em.isEmpty(journal) then '' else '.'}#{start}"
  ).property('doiPublisherPrefix', 'doiJournalPrefix', 'doiStartNumber')

  doiInvalid: (->
    Em.isEmpty(@get('doiPublisherPrefix')) ||
    Em.isEmpty(@get('doiStartNumber')) ||
    @get('doiStartNumberInvalid')
  ).property('doiPublisherPrefix', 'doiStartNumber')

  doiStartNumberInvalid: (->
    !$.isNumeric(@get('doiStartNumber'))
  ).property('doiStartNumber')

  actions:
    searchUsers: ->
      @resetSearch()
      @store.find 'AdminJournalUser', query: @get('searchQuery'), journal_id: @get('model.id')
      .then (users) =>
        @set 'adminJournalUsers', users
        if Em.isEmpty @get('adminJournalUsers')
          @set 'placeholderText', "No matching users found"

    epubCoverUploading: ->
      @set('epubCoverUploading', true)

    epubCoverUploaded: (data) ->
      @set('epubCoverUploading', false)
      journal = data.admin_journal
      @setProperties
        epubCoverUrl: journal.epub_cover_url
        epubCoverFileName: journal.epub_cover_file_name
        epubCoverUploadedAt: journal.epub_cover_uploaded_at

    resetSaveStatuses: ->
      @set('epubCssSaveStatus', '')
      @set('pdfCssSaveStatus', '')
      @set('manuscriptCssSaveStatus', '')

    editDOI: ->
      @set 'doiEditState', true

    cancelDOI: ->
      @get('model').rollback()
      @set 'doiEditState', false

    saveDOI: ->
      return if @get 'doiInvalid'

      @get('model').save()
      @set 'doiEditState', false
