`import Ember from 'ember'`
`import FileUploadMixin from 'tahi/mixins/controllers/file-upload'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`

JournalThumbnailController = Ember.ObjectController.extend FileUploadMixin, ValidationErrorsMixin,
  needs: ['application']
  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isEditing: (-> @get 'model.isDirty').property()
  thumbnailId: (-> "journal-logo-#{@get 'model.id'}").property()
  logoUploadUrl: (-> "/admin/journals/#{@get 'model.id'}/upload_logo").property('model.id')
  logoPreview: null
  journal: null
  uploadLogoFunction: null

  stopEditing: ->
    @setProperties(isEditing: false, uploadLogoFunction: null, logoPreview: null)

  saveJournal: ->
    @get('model').save()
                 .then =>
                   @stopEditing()
                 .catch (response) =>
                   @displayValidationErrorsFromResponse response

  actions:
    editJournalDetails: -> @set 'isEditing', true

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @set 'model.logoUrl', data.admin_journal.logo_url
      @saveJournal()

    saveJournalDetails: ->
      updateLogo = @get('uploadLogoFunction')
      if @get('model.isNew')
        @get('model').save()
                     .then (journal) =>
                       (updateLogo || @stopEditing).call(@)
                     .catch (response) =>
                       @displayValidationErrorsFromResponse response

      else
        # updateLogo will fire the 'uploadFinished' action from the component, thus saving the model
        # with the new journal logo url.
        (updateLogo || @saveJournal).call(@)

    resetJournalDetails: ->
      @get('model').rollback()
      @set 'isEditing', false
      @clearValidationErrors()

    showPreview: (file) ->
      @set 'logoPreview', file.preview

    uploadReady: (uploadLogoFunction) ->
      @set('uploadLogoFunction', uploadLogoFunction)

`export default JournalThumbnailController`
