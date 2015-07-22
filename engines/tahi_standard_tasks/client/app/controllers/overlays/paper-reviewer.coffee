`import TaskController from 'tahi/pods/paper/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`
`import { formatDate } from 'tahi/helpers/format-date'`

PaperReviewerOverlayController = TaskController.extend Select2Assignees,
  select2RemoteUrl: Ember.computed 'model.paper.id', ->
    "/api/filtered_users/reviewers/#{@get 'model.paper.id'}/"
  selectedReviewer: null
  resultsTemplate: (user) -> user.email
  selectedTemplate: (user) -> user.email
  composingEmail: false
  decisions: Ember.computed.alias 'model.paper.decisions'

  latestDecision: (->
    @get('decisions').findBy 'isLatest', true
  ).property('decisions', 'decisions.@each.isLatest')

  template: Ember.computed.alias 'model.editInviteTemplate'

  updatedTemplate: ''

  setTemplate: (->
    @setLetterTemplate()
  ).observes('selectedReviewer.id')

  setLetterTemplate: ->
    customTemplate = @get('template').replace(/\[REVIEWER NAME\]/, @get('selectedReviewer.full_name'))
      .replace(/\[YOUR NAME\]/, @get('currentUser.fullName'))

    @set('updatedTemplate', customTemplate)

  actions:
    cancelAction: ->
      @set 'selectedReviewer', null
      @set 'composingEmail', false

    composeInvite: ->
      return unless @get('selectedReviewer')
      @send 'letterTemplate'
      @set 'composingEmail', true

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
        @set 'composingEmail', false
        @set 'selectedReviewer', null

    letterTemplate: ->
      @get('template').replace(/\[REVIEWER NAME\]/, @get('selectedReviewer.full_name'))
        .replace(/\[YOUR NAME\]/, @get('currentUser.fullName'))

    removeReviewer: (selectedReviewer) ->
      @store.find('user', selectedReviewer.id).then (user) =>
        @get('reviewers').removeObject(user)
        @send('saveModel')

    setLetterBody: ->
      @set 'model.body', [@get('updatedTemplate')]
      @model.save()
      @send 'inviteReviewer'

`export default PaperReviewerOverlayController`
