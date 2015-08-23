`import TaskController from 'tahi/pods/paper/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`
`import Ember from 'ember'`

PaperEditorOverlayController = TaskController.extend Select2Assignees,
  restless: Ember.inject.service('restless')

  selectedUser: null
  composingEmail: false

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

  select2RemoteUrl: Ember.computed 'model.paper', ->
    "/api/filtered_users/editors/#{@get 'model.paper.id'}/"

  template: Ember.computed.alias 'model.invitationTemplate'

  setLetterTemplate: ->
    customTemplate = @get('template').replace(/\[EDITOR NAME\]/, @get('selectedUser.fullName'))
      .replace(/\[YOUR NAME\]/, @get('currentUser.fullName'))

    @set('updatedTemplate', customTemplate)

  actions:
    cancelAction: ->
      @set 'selectedUser', null
      @set 'composingEmail', false

    composeInvite: ->
      return unless @get('selectedUser')
      @setLetterTemplate()
      @set 'composingEmail', true

    didSelectEditor: (select2User) ->
      @store.find('user', select2User.id).then (user) => @set('selectedUser', user)

    removeEditor: ->
      promises = []
      promises.push(@get('restless').delete("/api/papers/#{@get('model.paper.id')}/editor"))
      promises.push(@get('model.invitation').destroyRecord()) if @get('model.invitation')
      Ember.RSVP.all(promises).then =>
        # TODO: Not dependant on server response - pretend editor is gone
        # There's currently no paper_role representation on the client.
        # Consider making editor a role instead of user.
        @get('model')._relationships['editor'].setCanonicalRecord(null)

    setLetterBody: ->
      @set 'model.body', [@get('updatedTemplate')]
      @model.save()
      @send 'inviteEditor'

    inviteEditor: ->
      invitation = @store.createRecord 'invitation',
        task: @get('model')
        email: @get('selectedUser.email')
      invitation.save().then => @get('model').set('invitation', invitation)
      @set 'composingEmail', false

    destroyInvitation: ->
      @get('model.invitation').destroyRecord()

`export default PaperEditorOverlayController`
