`import Ember from 'ember'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`

JournalIndexController = Ember.Controller.extend ValidationErrorsMixin,
  epubCssSaveStatus: ''
  pdfCssSaveStatus: ''
  manuscriptCssSaveStatus: ''
  doiEditState: false
  doiStartNumberEditable: true

  canDeleteManuscriptMangerTemplates: Ember.computed.gt('model.manuscriptManagerTemplates.length', 1)

  epubCoverUploadUrl: (->
    "/api/admin/journals/#{@get('model.id')}/upload_epub_cover"
  ).property()

  adminJournalUsers: null

  epubCoverUploading: false

  resetSearch: ->
    @set 'adminJournalUsers', null
    @set 'placeholderText', null

  logo: (->
    logoUrl = @get("model.logoUrl")
    if Ember.isEmpty(logoUrl)
      false
    else
      logoUrl
  ).property('model.logoUrl')

  journalUrl: (->
    "/admin/journals/#{@get('model.id')}"
  ).property('model.id')

  formattedDOI: (->
    if @get 'doiInvalid'
      ''
    else
      publisher = @get('doiPublisherPrefix')
      journal   = @get('doiJournalPrefix')
      start     = @get('lastDoiIssued')

      "#{publisher}/#{journal}#{if Ember.isEmpty(journal) then '' else '.'}#{start}"
  ).property('doiPublisherPrefix', 'doiJournalPrefix', 'lastDoiIssued')

  doiInvalid: (->
    Ember.isEmpty(@get('doiPublisherPrefix')) ||
    Ember.isEmpty(@get('lastDoiIssued')) ||
    @get('doiStartNumberInvalid')
  ).property('doiPublisherPrefix', 'lastDoiIssued')

  doiStartNumberInvalid: (->
    !$.isNumeric(@get('lastDoiIssued')) && !Ember.isEmpty(@get('doiStartNumber'))
  ).property('lastDoiIssued')


  actions:
    addRole: ->
      this.get('model.roles').addObject(this.store.createRecord('role'))

    addMMTemplate: ->
      @transitionTo('admin.journal.manuscript_manager_template.new')

    destroyMMTemplate: (template) ->
      if @get('canDeleteManuscriptMangerTemplates')
        template.destroyRecord().then =>
          @get('model.manuscriptManagerTemplates').removeObject(template)

    searchUsers: ->
      @resetSearch()
      @store.find 'AdminJournalUser', query: @get('searchQuery'), journal_id: @get('model.id')
      .then (users) =>
        @set 'adminJournalUsers', users
        if Ember.isEmpty @get('adminJournalUsers')
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
      @setProperties
        epubCssSaveStatus: ''
        pdfCssSaveStatus: ''
        manuscriptCssSaveStatus: ''

    editDOI: ->
      @set 'doiEditState', true

    cancelDOI: ->
      @get('model').rollback()
      @set 'doiEditState', false

    saveDOI: ->
      return if @get 'doiInvalid'

      @set 'doiStartNumberEditable', false
      @get('model').save()
        .then =>
          @set 'doiEditState', false
          @clearAllValidationErrors()
        , (response) =>
          @displayValidationErrorsFromResponse response

    assignRole: (roleId, user) ->
      userRole = @store.createRecord 'userRole',
        user: user
        role: @store.getById 'role', roleId

      userRole.save()
              .catch (res) ->
                userRole.transitionTo 'created.uncommitted'
                userRole.deleteRecord()

    removeRole: (userRoleId) ->
      @store.getById('userRole', userRoleId).destroyRecord()

`export default JournalIndexController`
