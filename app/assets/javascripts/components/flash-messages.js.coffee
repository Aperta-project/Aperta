ETahi.FlashMessagesComponent = Ember.Component.extend
  classNames: ['flash-messages']
  layoutName:  'flash-messages'

  actions:
    removeMessage: (message) ->
      @get('messages').removeObject message
