`import TaskController from 'tahi/pods/task/controller'`

FinancialDisclosureOverlayController = TaskController.extend
  task: Em.computed.alias("model")
  funders: Em.computed.alias("task.funders")
  paper: Em.computed.alias("task.paper")
  authors: Em.computed.alias('task.authors')
  receivedFunding: (->
    @get('funders.length') > 0
  ).property('funders.@each', 'funders.[]')
  receivedNoFunding: Em.computed.not('receivedFunding')

  actions:
    choseFundingReceived: ->
      if @get('funders.length') < 1
        @send('addFunder')

    choseFundingNotReceived: ->
      @get('funders').toArray().forEach (funder) ->
        if funder.get('isNew')
          funder.deleteRecord()
        else
          funder.destroyRecord()

    addFunder: ->
      @get('funders').pushObject(@store.createRecord('funder', task: @get('task')))

`export default FinancialDisclosureOverlayController`
