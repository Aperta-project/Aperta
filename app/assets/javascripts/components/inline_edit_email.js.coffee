ETahi.InlineEditEmailComponent = Em.Component.extend ETahi.AdhocInlineEditItem,
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

    sendEmail: (model) ->
      recipientIds = @get('recipients').map (r) -> r.get('id')
      bodyPart = @get 'bodyPart'
      bodyPart.sent = moment().format('MMMM Do YYYY')

      ETahi.RESTless.put("/adhoc_email/send_message", {body: bodyPart.value, subject: bodyPart.body, recipients: recipientIds, task_id: model.id})
      bodyPart.sent = moment().format('MMMM Do YYYY')
      @set 'lastSentDate', bodyPart.sent
      @toggleProperty 'showChooseReceivers'
      @toggleProperty 'emailSent'
      @send('save')

    removeRecipient: (recipient)->
      @get('recipients').removeObject(recipient)

    addRecipientById: (recipientId)->
      store = ETahi.__container__.lookup('store:main')
      store.find('user', recipientId).then (recipient)=>
        @get('recipients').pushObject(recipient)
