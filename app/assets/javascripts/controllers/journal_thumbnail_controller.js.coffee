ETahi.JournalThumbnailController = Ember.ObjectController.extend
  needs: ['application']
  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isEditing: (-> @get 'model.isDirty').property()

  nameErrors: null
  descriptionErrors: null

  resetErrors: ->
    @setProperties
      nameErrors: null
      descriptionErrors: null

  actions:
    editJournalDetails: ->
      @set 'isEditing', true

    saveJournalDetails: ->
      @get('model').save()
                   .then => @set 'isEditing', false
                   .catch (response) =>
                     @set 'nameErrors', response.errors.name?[0]
                     @set 'descriptionErrors', response.errors.description?[0]

    resetJournalDetails: ->
      @get('model').rollback()
      @set 'isEditing', false
      @resetErrors()
