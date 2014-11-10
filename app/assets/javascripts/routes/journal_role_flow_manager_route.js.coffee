ETahi.JournalRoleFlowManagerRoute = Ember.Route.extend
  model: (params) ->
    @store.find('role', params.role_id)

  afterModel: (model) ->
    model.get('flows')

  setupController: (controller, model) ->
    controller.setProperties
      model: model
      commentLooks: @store.all('commentLook')
      journal: @modelFor('journal')

  actions:
    viewCard: (task) ->
      paperId = task.get('litePaper.id')
      redirectParams = ['journal.role_flow_manager', @modelFor('journal'), @modelFor('journal.role_flow_manager')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'journal.role_flow_manager')
      @transitionTo('task', paperId, task.get('id'))
