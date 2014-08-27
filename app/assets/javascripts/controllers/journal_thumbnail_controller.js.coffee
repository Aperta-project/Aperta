ETahi.JournalThumbnailController = Ember.ObjectController.extend
  needs: ['application']
  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isEditing: (-> @get 'model.isDirty').property()
  thumbnailId: (-> "journal-logo-#{@get 'model.id'}").property()
  logoUploadUrl: (-> "/admin/journals/#{@get 'model.id'}/upload_logo").property()
  nameErrors: null
  descriptionErrors: null
  logoPreview: null
  journal: null


  resetErrors: ->
    @setProperties
      nameErrors: null
      descriptionErrors: null

  saveJournal: ->
    @get('model').save()
                 .then =>
                   @setProperties(isEditing: false, uploadLogoFunction: null, logoPreview: null)
                 .catch (response) =>
                   @set 'nameErrors', response.errors.name?[0]
                   @set 'descriptionErrors', response.errors.description?[0]

  actions:
    editJournalDetails: -> @set 'isEditing', true
    logoUploading: -> @set 'logoUploading', true

    saveJournalDetails: ->
      if @get('model.isNew')
        @get('model').save().then (journal)=>
          debugger
          updateLogo() if updateLogo = @get('uploadLogoFunction')
      else
        # updateLogo will fire the 'logoUploaded' action from the component, thus saving the model
        # with the new journal logo url.
        if updateLogo = @get('uploadLogoFunction')
          updateLogo()
        else
          @saveJournal()

    resetJournalDetails: ->
      @get('model').rollback()
      @set 'isEditing', false
      @resetErrors()

    logoUploaded: (data) ->
      @set 'model.logoUrl', data.admin_journal.logo_url
      @set 'logoUploading', false
      @saveJournal()

    showPreview: (file) ->
      @set 'logoPreview', file.preview

    uploadReady: (uploadLogoFunction) ->
      @set('uploadLogoFunction', uploadLogoFunction)
