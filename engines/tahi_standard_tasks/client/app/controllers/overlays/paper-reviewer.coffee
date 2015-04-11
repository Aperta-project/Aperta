`import TaskController from 'tahi/pods/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`
`import { formatDate } from 'tahi/helpers/format-date'`

PaperReviewerOverlayController = TaskController.extend Select2Assignees,
  select2RemoteUrl: Ember.computed 'model.paper.id', ->
    "/api/filtered_users/reviewers/#{@get 'model.paper.id'}/"
  selectedReviewer: null
  resultsTemplate: (user) -> user.email
  selectedTemplate: (user) -> user.email

  latestDecision: Ember.computed 'model.decisions.@each.isLatest', ->
    @get('model.decisions').findBy 'isLatest', true

  actions:
    destroyInvitation: (invitation) -> invitation.destroyRecord()
    didSelectReviewer: (selectedReviewer) ->
      @set 'selectedReviewer', selectedReviewer

    inviteReviewer: ->
      return unless @get('selectedReviewer')
      @store.createRecord 'invitation',
        task: @get 'model'
        email: @get 'selectedReviewer.email'
      .save().then (invitation) =>
        @get('latestDecision.invitations').addObject invitation
        @set 'selectedReviewer', null

    removeReviewer: (selectedReviewer) ->
      @store.find('user', selectedReviewer.id).then (user) =>
        @get('reviewers').removeObject(user)
        @send('saveModel')

`export default PaperReviewerOverlayController`
