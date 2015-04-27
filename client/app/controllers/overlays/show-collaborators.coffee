`import Ember from 'ember'`

ShowCollaboratorsOverlayController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen'

  availableCollaborators: Ember.computed.setDiff('allUsers', 'collaborators')

  formattedCollaborators: (->
    @get('availableCollaborators').map (collab) ->
      {id: collab.get('id'), text: collab.get('fullName')}
  ).property('availableCollaborators.@each')

  addedCollaborations: Ember.computed.setDiff('collaborations','initialCollaborations')
  removedCollaborations: Ember.computed.setDiff('initialCollaborations','collaborations')

  allUsers: null
  selectedCollaborator: null
  paper: null
  initialCollaborations: null
  collaborations: null

  collaborators: (->
    @get('collaborations').mapBy('user')
  ).property('collaborations.@each')

  actions:
    addNewCollaborator: (formattedOption) ->
      newCollaborator = this.get('availableCollaborators').findBy('id', formattedOption.id)
      paper = @get('paper')
      existingRecord = @store.all('collaboration').find (c) ->
        # if this collaborator's record was previously removed from the paper make sure we use THAT one and not a
        # new record.
        c.get('oldPaper') == paper && c.get('user') == newCollaborator

      newCollaboration = existingRecord || @store.createRecord('collaboration', paper: paper, user: newCollaborator)
      @get('collaborations').addObject(newCollaboration)

    removeCollaborator: (collaborator) ->
      collaboration = @get('collaborations').findBy('user', collaborator)
      # since the relationship between paper and collaboration is a proper hasMany, if we remove the
      # collaboration from the papers' collection of them ember will also unset the paper field on the collaboration.
      # if the user tries to re-add that collaborator to the paper without reloading we need to do some extra checking
      # to make sure that ember doesn't create a new record but rather uses the one we just removed here.
      collaboration.set('oldPaper', collaboration.get('paper'))
      @get('collaborations').removeObject(collaboration)
      @set('selectedCollaborator', null)

    cancel: ->
      collaborations = @get('collaborations')
      # we have to remove/add the changed collaborations from their associations individually
      @get('removedCollaborations').forEach (c) -> collaborations.addObject(c)
      @get('addedCollaborations').forEach (c) -> collaborations.removeObject(c)
      @send('closeOverlay')

    save: ->
      addPromises = @get('addedCollaborations').map (collaboration) =>
        collaboration.save()

      deletePromises = @get('removedCollaborations').map (collaboration) ->
        collaboration.destroyRecord()

      Ember.RSVP.all(_.union(addPromises, deletePromises)).then =>
        @send('closeOverlay')

`export default ShowCollaboratorsOverlayController`
