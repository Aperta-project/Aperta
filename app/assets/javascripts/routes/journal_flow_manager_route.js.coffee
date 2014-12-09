ETahi.JournalFlowManagerRoute = Ember.Route.extend
  model: (params) ->
    @store.find('role', params.role_id)

  afterModel: (model) ->
    model.get('flows')

  renderTemplate: ->
    @_super()
    @render 'flow-manager-buttons',
      outlet: 'controlBarButtons'
      template: 'journal'

  setupController: (controller, model) ->
    controller.setProperties
      model: model
      commentLooks: @store.all('commentLook')
      journal: @modelFor('journal')
      journalTaskTypes: @store.all('journalTaskType')

  actions:
    viewCard: (task) ->
      paperId = task.get('litePaper.id')
      redirectParams = ['journal.flow_manager', @modelFor('journal'), @modelFor('journal.flow_manager')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'journal.flow_manager')
      @transitionTo('task', paperId, task.get('id'))
