ETahi.FunderController = Ember.ObjectController.extend
  allAuthors: Em.computed.alias('task.authors')
  fundedAuthors: Em.computed.oneWay('model.authors')

  actions:
    addFundedAuthors:  ->
      @get('model.authors').setObjects(@get('fundedAuthors'))

    funderDidChange: ->
      @get('model').save()

