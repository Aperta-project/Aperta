ETahi.NewTaskController = Ember.Controller.extend
  actions:
    createCard: ->
      @get('task').save()
