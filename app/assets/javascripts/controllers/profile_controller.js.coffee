ETahi.ProfileController = Ember.ObjectController.extend
  needs: ['fileUpload'],
  hideAffiliationForm: true

  errorText: ""

  affiliations: Ember.computed.alias "model.affiliationsByDate"

  avatarUploadUrl: ( ->
    "/users/#{@get('id')}/update_avatar"
  ).property('id')

  uploads: []
  isUploading: false
  uploadsDidChange: (->
    @set 'isUploading', !!this.get('uploads.length')
  ).observes('uploads.@each')

  actions:
    uploadStarted: (data, fileUploadXHR)->
      @get('controllers.fileUpload').send('uploadStarted', data, fileUploadXHR)
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data)->
      @get('controllers.fileUpload').send('uploadProgress', data)

    uploadFinished: (data, filename) ->
      @get('controllers.fileUpload').send('uploadFinished', data, filename)
      @set('model.avatarUrl', data.avatar_url)
      uploads = @get('uploads')
      newUpload = uploads.findBy('file.name', filename)
      uploads.removeObject newUpload

    cancelUploads: ->
      @get('controllers.fileUpload').send('cancelUploads')
      @set('uploads', [])

    toggleAffiliationForm: ->
      @set('newAffiliation', @store.createRecord('affiliation'))
      @toggleProperty('hideAffiliationForm')
      false

    removeAffiliation: (affiliation) ->
      if confirm("Are you sure you want to destroy this affiliation?")
        affiliation.destroyRecord()

    commitAffiliation:(affiliation) ->
      affiliation.set('user', @get('model'))
      affiliation.save().then(
        (affiliation) =>
          affiliation.get('user.affiliations').addObject(affiliation)
          @send('toggleAffiliationForm')
        ,
        (errorResponse) =>
          affiliation.set('user', null)
          errors = for key, value of errorResponse.errors
            messages = for msg in value
              # TODO: Use this in the other error handlers.
              "#{key.dasherize().capitalize().replace("-", " ")} #{value}"
            messages.join(", ")
          Tahi.utils.togglePropertyAfterDelay(@, 'errorText', errors.join(', '), '', 5000)
      )
