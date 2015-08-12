`import TaskController from 'tahi/pods/paper/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`
`import { formatDate } from 'tahi/helpers/format-date'`

PaperReviewerOverlayController = TaskController.extend Select2Assignees,
  autoSuggestSourceUrl: Ember.computed 'model.paper.id', ->
    "/api/filtered_users/uninvited_users/#{@get 'model.paper.id'}"
  selectedReviewer: null
  composingEmail: false
  decisions: Ember.computed.alias 'model.paper.decisions'

  customEmail: "test@lvh.me"

  latestDecision: (->
    @get('decisions').findBy 'isLatest', true
  ).property('decisions', 'decisions.@each.isLatest')

  applyTemplateReplacements: (str) ->
    reviewerName = @get('selectedReviewer.full_name')
    if reviewerName
      str = str.replace /\[REVIEWER NAME\]/g, reviewerName
    str.replace(/\[YOUR NAME\]/g, @get('currentUser.fullName'))

  setLetterTemplate: ->
    template = @get('model.invitationTemplate')

    if template.salutation and @get('selectedReviewer.full_name')
      salutation = @applyTemplateReplacements(template.salutation) + "\n\n"
    else
      salutation = ""

    if template.body
      body = @applyTemplateReplacements(template.body)
    else
      body = ""

    @set('invitationBody', "#{salutation}#{body}")

  parseUserSearchResponse: (response) ->
    response.filtered_users

  displayUserSelected: (user) ->
    "#{user.full_name} [#{user.email}]"

  actions:
    cancelAction: ->
      @set 'selectedReviewer', null
      @set 'composingEmail', false

    composeInvite: ->
      return unless @get('selectedReviewer')
      @setLetterTemplate()
      @set 'composingEmail', true

    destroyInvitation: (invitation) -> invitation.destroyRecord()

    didSelectReviewer: (selectedReviewer) ->
      @set 'selectedReviewer', selectedReviewer

    inviteReviewer: ->
      return unless @get('selectedReviewer')
      @store.createRecord 'invitation',
        task: @get 'model'
        email: @get 'selectedReviewer.email'
        body: @get 'invitationBody'
      .save().then (invitation) =>
        @get('latestDecision.invitations').addObject invitation
        @set 'composingEmail', false
        @set 'selectedReviewer', null

    removeReviewer: (selectedReviewer) ->
      @store.find('user', selectedReviewer.id).then (user) =>
        @get('reviewers').removeObject(user)
        @send('saveModel')

    inputChanged: (val) ->
      @set 'selectedReviewer', { email: val }


`export default PaperReviewerOverlayController`
