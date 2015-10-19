`import TaskController from "tahi/pods/paper/task/controller"`

FinancialDisclosureOverlayController = TaskController.extend
  task: Em.computed.alias("model")
  funders: Em.computed.alias("task.funders")
  paper: Em.computed.alias("task.paper")

  # ye olde tri-state boolean (explicit selection)
  receivedFunding: null

  numFundersObserver: (->
    # No explicitly chosen, bail
    return if @get("receivedFunding") == false
    if @get("funders.length") > 0
      # definitely funders, choose Yes
      @set("receivedFunding", true)
      @set("task.questions.firstObject.answer", "Yes")
    else
      # require explicit selection of No
      @set("receivedFunding", null)
      if @get("task.questions.firstObject.answer")
        @set("task.questions.firstObject.answer", null)
  ).observes("funders.[]")

  actions:
    choseFundingReceived: ->
      # explicitly choose Yes
      @set("receivedFunding", true)
      if @get("funders.length") < 1
        @send("addFunder")

    choseFundingNotReceived: ->
      # explicitly choose No
      @set("receivedFunding", false)
      @get("funders").toArray().forEach (funder) ->
        if funder.get("isNew")
          funder.deleteRecord()
        else
          funder.destroyRecord()

    addFunder: ->
      @store.createRecord("funder", task: @get("task")).save()

`export default FinancialDisclosureOverlayController`
