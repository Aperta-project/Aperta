`import Ember from 'ember'`

Flash = Ember.Object.extend
  messages: []

  displayMessage: (type, message) ->
    @get('messages').pushObject
      text: message
      type: type

  displayErrorMessagesFromResponse: (response) ->
    errors = (for own key, value of response.errors
      "#{key.underscore().replace('_', ' ').capitalize()} #{value}"
    )
    errors.forEach (message) =>
      @displayMessage 'error', message

  clearMessages: ->
    @set 'messages', []

`export default Flash`
