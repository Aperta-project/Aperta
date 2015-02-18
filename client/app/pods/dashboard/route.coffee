`import Ember from 'ember'`

DashboardRoute = Ember.Route.extend
  model: ->
    @store.find('dashboard').then (dashboardArray) ->
      dashboardArray.get 'firstObject'

  setupController: (controller, model) ->
    @store.find('commentLook') # don't wait to fulfill
    controller.set('model', model)
    papers = @store.filter 'litePaper', (p) ->
      !Ember.isEmpty p.get('roles')

    controller.set('papers', papers)
    controller.set('unreadComments', @store.all('commentLook'))

  actions:
    didTransition: () ->
      @controllerFor('dashboard').set 'pageNumber', 1
      return true

    rejectInvitation: (invitation) ->
      invitation.reject()
      invitation.save().then =>
        @send('closeOverlay')

    acceptInvitation: (invitation) ->
      invitation.accept()
      invitation.save().then =>
        @store.find('dashboard')
        @send('closeOverlay')

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
