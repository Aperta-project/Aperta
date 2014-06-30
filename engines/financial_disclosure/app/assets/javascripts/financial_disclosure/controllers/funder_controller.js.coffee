ETahi.FunderController = Ember.ObjectController.extend ETahi.SavesDelayed,
  allAuthors: Em.computed.alias('task.authors')
  fundedAuthors: Em.computed.oneWay('model.authors')
  authorsTask: Em.computed.alias('task.authorsTask')

  actions:
    addFundedAuthors:  ->
      @get('model.authors').setObjects(@get('fundedAuthors'))

    funderDidChange: ->
      #saveModel is implemented in ETahi.SavesDelayed
      @send('saveModel')
