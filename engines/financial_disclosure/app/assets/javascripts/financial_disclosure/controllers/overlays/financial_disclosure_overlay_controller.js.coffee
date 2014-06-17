ETahi.FinancialDisclosureOverlayController = ETahi.TaskController.extend
  task: Em.computed.alias("model")
  funders: Em.computed.alias("task.funders")
  paper: Em.computed.alias("task.paper")
  authors: Em.computed.alias("paper.authors")
  receivedFunding: (->
    @get('funders.length') > 0
  ).property('funders.@each, funders.[]')
  receivedNoFunding: Em.computed.not('receivedFunding')

  actions:
    choseFundingReceived: ->
      funders = @get('funders')
      if funders.get('length') < 1
        funders.pushObject(@store.createRecord('funder', task: @get('task')))

    choseFundingNotReceived: ->
      @get('funders').forEach (funder) ->
        funder.deleteRecord()
