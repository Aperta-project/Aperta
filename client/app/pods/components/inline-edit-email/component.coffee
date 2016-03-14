`import Ember from 'ember'`
`import getOwner from 'ember-getowner-polyfill'`

InlineEditEmailComponent = Ember.Component.extend
  editing: false
  isNew: false
  bodyPart: null
  bodyPartType: Ember.computed.alias('bodyPart.type')

  isSendable: true
  showChooseReceivers: false
  mailRecipients: []
  recipients: []
  allUsers: null
  overlayParticipants: null
  emailSentStates: Ember.computed.alias 'parentView.emailSentStates'

  lastSentAt: null

  initRecipients: (->
    return unless @get('showChooseReceivers')
    @set 'recipients', @get('overlayParticipants').map (p) =>
      p.get('user')
  ).observes('showChooseReceivers')

  keyForStates: Ember.computed.alias 'bodyPart.subject'

  showSentMessage: ( ->
    if @get('isSendable')
      key = @get('keyForStates')
      @get('emailSentStates').contains(key)
    else
      false
  ).property('keyForStates', 'emailSentStates.[]')

  setSentState: ->
    key = @get('keyForStates')
    @get('emailSentStates').addObject(key)

  actions:
    toggleChooseReceivers: ->
      @toggleProperty 'showChooseReceivers'

    clearEmailSent: ->
      @get('emailSentStates').removeObject(@get('keyForStates'))

    sendEmail: ->
      recipientIds = @get('recipients').mapBy('id')
      bodyPart = @get('bodyPart')
      bodyPart.sent = moment().format('MMMM Do YYYY')
      @set('lastSentAt', bodyPart.sent)
      // TODOMPM - Email recipients is not sending correctly
      @.attrs.sendEmail
        body: bodyPart.value
        subject: bodyPart.subject
        recipients: recipientIds

      @set('showChooseReceivers', false)
      @setSentState()

    removeRecipient: (recipient)->
      @get('recipients').removeObject(recipient)

    addRecipientById: (recipientId)->
      store = getOwner(@).lookup('store:main')
      store.find('user', recipientId).then (recipient)=>
        @get('recipients').addObject(recipient)

`export default InlineEditEmailComponent`
