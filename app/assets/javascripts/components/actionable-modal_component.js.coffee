ETahi.ActionableModalComponent = Em.Component.extend
  modalId: (->
    "#{@get('username')}-modal"
  ).property('username')

  actions:
    perform: ->
      @sendAction 'saveAction'

    cancel: ->
      @sendAction 'cancelAction'
