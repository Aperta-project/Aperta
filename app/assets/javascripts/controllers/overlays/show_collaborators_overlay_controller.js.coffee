ETahi.ShowCollaboratorsOverlayController = Em.ObjectController.extend
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  availableCollaborators: Ember.computed.setDiff('allUsers', 'collaborators')

  collaborators: null

  actions:
    addNewCollaborator: (newCollaborator) ->
      @get('collaborators').addObject(newCollaborator)
