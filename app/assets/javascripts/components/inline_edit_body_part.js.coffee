ETahi.InlineEditBodyPartComponent = Em.Component.extend
  editing: false
  snapshot: null
  confirmDelete: false
  showChooseReceivers: false
  emailSent: false
  mailRecipients: []
  lastSentDate: null
  recipients: []
  overlayParticipants: null

  _init: (->
    @set 'snapshot', []
    @set 'lastSentDate', @get('block.firstObject.sent')
    @initRecipients()
  ).on('init')

  initRecipients: (->
    @set('recipients', @get('overlayParticipants').copy())
  ).observes('showChooseReceivers')

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('block'), true))
  ).observes('editing')

  hasContent: (->
    @get('block').any(@_isNotEmpty)
  ).property('block.@each.value')

  hasNoContent: Em.computed.not('hasContent')

  bodyPartType: (->
    @get('block.firstObject.type')
  ).property('block.@each.type')

  isSendable: (->
    @get('bodyPartType') == "email"
  ).property('bodyPartType')

  _isNotEmpty: (item) ->
    item && !Em.isEmpty(item.value)

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('block'), @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    deleteBlock: ->
      @sendAction('delete', @get('block'))

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('block'))
        @toggleProperty 'editing'

    toggleConfirmDeletion: ->
      @toggleProperty 'confirmDelete'

    toggleChooseReceivers: ->
      @toggleProperty 'showChooseReceivers'

    toggleEmailSent: ->
      @toggleProperty 'emailSent'

    sendEmail: ->
      recipientIds = @get('recipients').map (r) -> r.get('id')
      block = @get 'block.firstObject'
      @send('save')

      ETahi.RESTless.put("/adhoc_email/send_message", {body: block.value, subject: block.body, recipients: recipientIds})
      block.sent = moment().format('MMMM Do YYYY')
      @set 'lastSentDate', block.sent
      @toggleProperty 'showChooseReceivers'
      @toggleProperty 'emailSent'

    addItem: ->
      @sendAction('addItem', @get('block'))

    removeRecipient: (recipient)->
      @get('recipients').removeObject(recipient)

    addRecipientById: (recipientId)->
      store = ETahi.__container__.lookup('store:main')
      store.find('user', recipientId).then (recipient)=>
        @get('recipients').pushObject(recipient)
