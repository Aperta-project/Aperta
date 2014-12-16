`import Ember from 'ember'`
`import FileUploadMixin from 'tahi/mixins/controllers/file-upload'`

JournalThumbnailController = Ember.ObjectController.extend FileUploadMixin,
  needs: ['application']
  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isEditing: (-> @get 'model.isDirty').property()
  thumbnailId: (-> "journal-logo-#{@get 'model.id'}").property()
  logoUploadUrl: (-> "/admin/journals/#{@get 'model.id'}/upload_logo").property('model.id')
  nameErrors: null
  descriptionErrors: null
  logoPreview: null
  journal: null
  uploadLogoFunction: null

  resetErrors: ->
    @setProperties
      nameErrors: null
      descriptionErrors: null

  stopEditing: ->
    @setProperties(isEditing: false, uploadLogoFunction: null, logoPreview: null)

  saveJournal: ->
    self = @
    @get('model').save()
      .then(@stopEditing.bind(@))
      .catch ({errors: {name, description}}) ->
        self.setProperties
          nameErrors: name?[0]
          descriptionErrors: description?[0]

  actions:
    editJournalDetails: -> @set 'isEditing', true

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @set 'model.logoUrl', data.admin_journal.logo_url
      @saveJournal()

    saveJournalDetails: ->
      updateLogo = @get('uploadLogoFunction')
      if @get('model.isNew')
        @get('model').save().then (journal) =>
          (updateLogo || @stopEditing).call(@)
      else
        # updateLogo will fire the 'uploadFinished' action from the component, thus saving the model
        # with the new journal logo url.
        (updateLogo || @saveJournal).call(@)

    resetJournalDetails: ->
      @get('model').rollback()
      @set 'isEditing', false
      @resetErrors()

    showPreview: (file) ->
      @set 'logoPreview', file.preview

    uploadReady: (uploadLogoFunction) ->
      @set('uploadLogoFunction', uploadLogoFunction)

`export default JournalThumbnailController`
