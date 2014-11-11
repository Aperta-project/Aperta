ETahi.JournalRoleFlowManagerRoute = Ember.Route.extend
  model: (params) ->
    @store.find('role', params.role_id)

  afterModel: (model) ->
    model.get('flows')

  renderTemplate: ->
    @_super()
    @render 'role-flow-manager-buttons',
      outlet: 'controlBarButtons'
      template: 'journal'

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

    saveFlow: (flow) ->
      flow.save()

    removeFlow: (flow) ->
      flow.destroyRecord()

    addFlow: ->
      flow = @store.createRecord 'roleFlow',
        title: 'Up for grabs'
        role: @modelFor('journal.role_flow_manager')
      flow.save().then (flow) => # SSOT workaround
        flow.get('role.flows').addObject(flow)

