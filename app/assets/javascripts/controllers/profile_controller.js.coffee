ETahi.ProfileController = Ember.ObjectController.extend ETahi.FileUploadMixin,
  hideAffiliationForm: true

  errorText: ""

  affiliations: Ember.computed.alias "model.affiliationsByDate"

  avatarUploadUrl: ( ->
    "/users/#{@get('id')}/update_avatar"
  ).property('id')

  selectableInstitutions: (->
    @get('institutions').map (institution) ->
      id: institution
      text: institution
  ).property('institutions')

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @set('model.avatarUrl', data.avatar_url)

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
