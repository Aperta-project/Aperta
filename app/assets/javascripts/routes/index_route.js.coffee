ETahi.IndexRoute = Ember.Route.extend
  beforeModel: ->
    store = @store
    Ember.$.getJSON('/users/dashboard_info').then (data)->
      store.pushPayload('dashboard', data)

  model: ->
    @store.all('dashboard').get('firstObject')

  afterModel: (model) ->
    assignedTasks = model.get('assignedTasks')
    assignedPapers = Ember.RSVP.all(assignedTasks.mapBy('paper')).then (papers) ->
      tasksByPaper = papers.map (paper) ->
        tasks = assignedTasks.filterBy('paper.content', paper)
        { shortTitle: paper.get('shortTitle'), id: paper.get('id'), tasks: tasks }
      model.set('tasksByPaper', tasksByPaper)

  actions:
    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'index')
      task.get('paper').then (paper) =>
        @transitionTo('task', paper.get('id'), task.id)
