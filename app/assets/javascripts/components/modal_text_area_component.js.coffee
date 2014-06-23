ETahi.ModalTextAreaComponent = Em.Component.extend
  modalId: (->
    "#{@get('name')}-modal"
  ).property()

  actions:
    saveAttr: ->
      @sendAction 'action', @get('name')

    resetSaveStatuses: ->
      @sendAction 'resetSaveStatusAction'
