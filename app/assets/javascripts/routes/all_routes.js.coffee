ETahi.ApplicationRoute = Ember.Route.extend
  actions:
    showTaskOverlay: (task) ->
      taskName = task.get('type').replace(/Task$/,'')
      @controllerFor('task').set('model', task)
      @render(taskName,
        into: 'application'
        outlet: 'overlay'
        controller: 'task')

    closeOverlay: ->
      @disconnectOutlet(
        outlet: 'overlay'
        parentView: 'application')

ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

ETahi.PaperManageRoute = Ember.Route.extend
  model: ->
    @modelFor 'paper'


