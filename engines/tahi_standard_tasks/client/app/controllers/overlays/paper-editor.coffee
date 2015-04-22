`import TaskController from 'tahi/pods/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`
`import RESTless from 'tahi/services/rest-less'`
`import Ember from 'ember'`

PaperEditorOverlayController = TaskController.extend Select2Assignees,

  selectedUser: null

  hasInvitedInvitation: Ember.computed.equal('model.invitation.state', 'invited')
  hasRejectedInvitation: Ember.computed.equal('model.invitation.state', 'rejected')

  showEditorSelect: (->
    return false if @get('model.editor')
    return true if Ember.isEmpty(@get('model.invitation'))
    @get('model.invitation.state') == "accepted"
  ).property('model.editor', 'model.invitation', 'model.invitation.state')

  select2RemoteSource: (->
    url: @get('select2RemoteUrl')
    dataType: "json"
    quietMillis: 500
    data: (term) ->
      query: term
    results: (data) ->
      results: data.filtered_users
  ).property('select2RemoteUrl')

  resultsTemplate: (user) ->
    user.email

  selectedTemplate: (user) ->
    user.email || user.get('email')

  select2RemoteUrl: Ember.computed 'model.paper', ->
    "/api/filtered_users/editors/#{@get 'model.paper.id'}/"

  actions:

    didSelectEditor: (select2User) ->
      @store.find('user', select2User.id).then (user) => @set('selectedUser', user)

    removeEditor: ->
      promises = []
      promises.push(RESTless.delete("/api/papers/#{@get('model.paper.id')}/editor"))
      promises.push(@get('model.invitation').destroyRecord()) if @get('model.invitation')
      Ember.RSVP.all(promises).then =>
        # TODO: Not dependant on server response - pretend editor is gone
        # There's currently no paper_role representation on the client.
        # Consider making editor a role instead of user.
        @get('model')._relationships['editor'].setCanonicalRecord(null)

    sendInvitation: ->
      @send('saveModel')

    inviteEditor: ->
      invitation = @store.createRecord 'invitation',
        task: @get('model')
        email: @get('selectedUser.email')
      invitation.save().then => @get('model').set('invitation', invitation)

    destroyInvitation: ->
      @get('model.invitation').destroyRecord()

`export default PaperEditorOverlayController`
