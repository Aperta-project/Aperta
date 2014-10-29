ETahi.InlineEditEmailComponent = Em.Component.extend ETahi.AdhocInlineEditItem,
  isSendable: true
  showChooseReceivers: false
  emailSent: false
  mailRecipients: []
  recipients: []
  allUsers: null
  overlayParticipants: null

  initRecipients: (->
    @set('recipients', @get('overlayParticipants').copy())
  ).observes('showChooseReceivers')

  actions:
    toggleChooseReceivers: ->
      @toggleProperty 'showChooseReceivers'

    toggleEmailSent: ->
      @toggleProperty 'emailSent'

    sendEmail: ->
      recipientIds = @get('recipients').mapBy('id')
      bodyPart = @get('bodyPart')
      bodyPart.sent = moment().format('MMMM Do YYYY')
      @sendAction("sendEmail", body: bodyPart.value, subject: bodyPart.subject, recipients: recipientIds)
      @toggleProperty 'showChooseReceivers'
      @toggleProperty 'emailSent'
      @get('parentView').send('save')

    removeRecipient: (recipient)->
      @get('recipients').removeObject(recipient)

    addRecipientById: (recipientId)->
      store = @container.lookup('store:main')
      store.find('user', recipientId).then (recipient)=>
        @get('recipients').addObject(recipient)
