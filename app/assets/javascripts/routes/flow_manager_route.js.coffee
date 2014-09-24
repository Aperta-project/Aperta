ETahi.FlowManagerRoute = ETahi.AuthorizedRoute.extend
  beforeModel: (transition) ->
    @handleUnauthorizedRequest(transition) unless @getCurrentUser? and @getCurrentUser().get('admin')

  model: ->
    if cachedModel =  @controllerFor('application').get('cachedModel')
      @controllerFor('application').set('cachedModel' , null)
      cachedModel
    else
      @store.find('flow')

  afterModel: ->
    @store.find('commentLook')

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('commentLooks', @store.all('commentLook'))

  actions:
    chooseNewFlowMangerColumn: ->
      @render('chooseNewFlowManagerColumnOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewFlowManagerColumnOverlay')

    removeFlow: (flow) ->
      flow.destroyRecord()

    viewCard: (task) ->
      paperId = task.get('litePaper.id')
      redirectParams = ['flow_manager']
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('cachedModel' , @modelFor('flow_manager'))
      @controllerFor('application').set('overlayBackground', 'flow_manager')
      @transitionTo('task', paperId, task.get('id'))
