ETahi.InlineEditEmailComponent = Em.Component.extend ETahi.AdhocInlineEditItem,
  isSendable: true
  showChooseReceivers: false
  mailRecipients: []
  recipients: []
  allUsers: null
  overlayParticipants: null
  emailSentStates: Ember.computed.alias 'parentView.emailSentStates'

  initRecipients: (->
    @set('recipients', @get('overlayParticipants').copy())
  ).observes('showChooseReceivers')

  keyForStates: Ember.computed.alias 'bodyPart.subject'

  showSentMessage: ( ->
    key = @get('keyForStates')
    @get('emailSentStates').contains(key)
  ).property('keyForStates', 'emailSentStates.@each')

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
      @sendAction("sendEmail", body: bodyPart.value, subject: bodyPart.subject, recipients: recipientIds)
      @set('showChooseReceivers', false)
      @setSentState()
      @get('parentView').send('save')

    removeRecipient: (recipient)->
      @get('recipients').removeObject(recipient)

    addRecipientById: (recipientId)->
      store = @container.lookup('store:main')
      store.find('user', recipientId).then (recipient)=>
        @get('recipients').addObject(recipient)
