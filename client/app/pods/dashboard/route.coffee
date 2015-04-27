`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

DashboardRoute = Ember.Route.extend
  model: ->
    @store.find('dashboard').then (dashboardArray) ->
      dashboardArray.get 'firstObject'

  setupController: (controller, model) ->
    @store.find('commentLook') # don't wait to fulfill
    controller.set('model', model)
    papers = @store.filter 'paper', (p) ->
      !Ember.isEmpty p.get('roles')

    controller.set('papers', papers)
    controller.set('unreadComments', @store.all('commentLook'))
    controller.set 'invitations', @store.filter 'invitation', (invitation) =>
      invitation.get('state') is "invited" and invitation.get("inviteeId") is @currentUser.get("id")

  actions:
    didTransition: () ->
      @controllerFor('dashboard').set 'pageNumber', 1
      true

    rejectInvitation: (invitation) ->
      RESTless.putModel(invitation, '/reject').then -> invitation.reject()
    acceptInvitation: (invitation) ->
      RESTless.putModel(invitation, '/accept').then =>
        invitation.accept()
        @store.find('dashboard')

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
