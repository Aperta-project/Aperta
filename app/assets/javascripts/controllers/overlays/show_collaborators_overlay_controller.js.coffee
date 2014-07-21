ETahi.ShowCollaboratorsOverlayController = Em.ObjectController.extend
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  availableCollaborators: Ember.computed.setDiff('allUsers', 'collaborators')

  addedcollaborations: Ember.computed.setDiff('collaborations.content','initialcollaborations')
  removedcollaborations: Ember.computed.setDiff('initialcollaborations','collaborations')

  paper: null
  initialcollaborations: null
  collaborations: null

  collaborators: (->
    @get('collaborations').mapBy('user')
  ).property('collaborations.@each')

  actions:
    addNewCollaborator: (newCollaborator) ->
      newCollaboration = @store.createRecord('collaboration', paper: @get('paper'), user: newCollaborator)
      @get('collaborations').addObject(newCollaboration)

    save: ->
      @get('addedCollaborations').forEach (collaboration) =>
        collaboration.save()

      @get('removedCollaborations').forEach (collaboration) ->
        collaboration.destroyRecord()

