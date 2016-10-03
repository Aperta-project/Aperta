import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),
  isSendable: true,
  showChooseReceivers: false,
  mailRecipients: [],
  recipients: null,
  overlayParticipants: null,
  emailSentStates: null,
  lastSentAt: null,
  store: Ember.inject.service(),

  initRecipients: Ember.observer('showChooseReceivers', function() {
    if (!this.get('showChooseReceivers')) { return; }

    this.set('recipients', this.get('overlayParticipants').slice());
  }),

  keyForStates: Ember.computed.alias('bodyPart.subject'),

  showSentMessage: Ember.computed('keyForStates', 'emailSentStates.[]', function() {
    if (this.get('isSendable')) {
      let key = this.get('keyForStates');
      return this.get('emailSentStates').includes(key);
    } else {
      return false;
    }
  }),

  setSentState: function() {
    let key = this.get('keyForStates');
    return this.get('emailSentStates').addObject(key);
  },

  actions: {
    toggleChooseReceivers: function() {
      return this.toggleProperty('showChooseReceivers');
    },

    clearEmailSent: function() {
      return this.get('emailSentStates').removeObject(this.get('keyForStates'));

    },

    sendEmail: function() {
      var bodyPart, recipientIds;
      recipientIds = this.get('recipients').mapBy('id');
      bodyPart = this.get('bodyPart');
      bodyPart.sent = moment().format('MMMM Do YYYY');
      this.set('lastSentAt', bodyPart.sent);
      this.attrs.sendEmail({
        body: bodyPart.value,
        subject: bodyPart.subject,
        recipients: recipientIds
      });
      this.set('showChooseReceivers', false);
      return this.setSentState();

    },

    removeRecipient: function(recipient) {
      return this.get('recipients').removeObject(recipient);
    },

    addRecipient: function(newRecipient, availableRecipients) {
      var recipient, store, user;
      store = this.get('store');
      recipient = availableRecipients.findBy('id', newRecipient.id);
      user = store.findOrPush('user', recipient);
      return this.get('recipients').addObject(recipient);
    }
  }
});
