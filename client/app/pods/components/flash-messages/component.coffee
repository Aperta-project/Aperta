`import Ember from 'ember'`

FlashMessagesComponent = Ember.Component.extend
  classNames: ['flash-messages']
  layoutName:  'flash-messages'

  actions:
    removeMessage: (message) ->
      @get('flash.messages').removeObject message

`export default FlashMessagesComponent`
