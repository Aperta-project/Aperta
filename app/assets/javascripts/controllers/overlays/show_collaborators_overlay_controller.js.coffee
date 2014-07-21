ETahi.ShowCollaboratorsOverlayController = Em.ObjectController.extend
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  availableCollaborators: Ember.computed.setDiff('allUsers', 'collaborators')

  addedCollaborations: Ember.computed.setDiff('collaborations.content','initialCollaborations')
  removedCollaborations: Ember.computed.setDiff('initialCollaborations','collaborations')

  paper: null
  initialCollaborations: null
  collaborations: null

  collaborators: (->
    @get('collaborations').mapBy('user')
  ).property('collaborations.@each')

  actions:
    addNewCollaborator: (newCollaborator) ->
      newCollaboration = @store.createRecord('collaboration', paper: @get('paper'), user: newCollaborator)
      @get('collaborations').addObject(newCollaboration)

    save: ->
      addPromises = @get('addedCollaborations').map (collaboration) =>
        collaboration.save()

      deletePromises = @get('removedCollaborations').map (collaboration) ->
        collaboration.destroyRecord()

      Ember.RSVP.all(_.union(addPromises, deletePromises)).then =>
        @send('closeOverlay')
