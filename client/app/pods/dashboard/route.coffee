`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

DashboardRoute = Ember.Route.extend
  model: ->
    Ember.RSVP.hash
      papers: @store.find('paper')
      invitations: @store.find('invitation')
      commentLooks: @store.find('commentLook')

  setupController: (controller, model) ->
    controller.set('unreadComments', model.commentLooks)
    controller.set("papers", model.papers)
    controller.set("invitations", @currentUser.get("invitedInvitations"))

    @_super(controller, model)

  actions:
    didTransition: () ->
      @controllerFor('dashboard').set 'pageNumber', 1
      true

    rejectInvitation: (invitation) ->
      RESTless.putModel(invitation, '/reject').then -> invitation.reject()

    acceptInvitation: (invitation) ->
      RESTless.putModel(invitation, '/accept').then -> invitation.accept()

    showNewPaperOverlay: () ->
      @store.find('journal').then (journals) =>
        model = @store.createRecord 'paper',
          journal: journals.get('content.firstObject')
          paperType: journals.get('content.firstObject.paperTypes.firstObject')
          editable: true
          body: ''

        @controllerFor('overlays/paperNew').setProperties
          model: model
          journals: journals

        @render 'overlays/paperNew',
          into: 'application'
          outlet: 'overlay'
          controller: 'overlays/paperNew'

    viewInvitations: (invitations) ->
      @controllerFor('overlays/invitations').set('model', invitations)

      @render 'overlays/invitations',
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/invitations'

`export default DashboardRoute`
