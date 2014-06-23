ETahi.ActionableModalComponent = Em.Component.extend
  modalId: (->
    "#{@get('username')}-modal"
  ).property()

  actions:
    perform: ->
      @sendAction 'saveAction'

    cancel: ->
      @sendAction 'cancelAction'
