import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  bodyPart: null,
  bodyPartType: Ember.computed.alias('bodyPart.type'),
  isSendable: Ember.computed.notEmpty('recipients'),
  showChooseReceivers: false,
  recipients: null,
  overlayParticipants: null,
  emailSentStates: null,
  lastSentAt: Ember.computed.reads('bodyPart.sent'),
  store: Ember.inject.service(),
  searchingParticipant: false,

  initRecipients: Ember.observer('showChooseReceivers', function() {
    if (!this.get('showChooseReceivers')) { return; }

    this.set('recipients', this.get('overlayParticipants').slice());
  }),

  keyForStates: Ember.computed.alias('bodyPart.subject'),

  showSentMessage: Ember.computed('keyForStates', 'emailSentStates.[]', function() {
    let key = this.get('keyForStates');
    return this.get('emailSentStates').includes(key);
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
      this.set('bodyPart.sent', moment().format('MMMM Do YYYY'));
      this.get('sendEmail')({
        body: bodyPart.value,
        subject: bodyPart.subject,
        recipients: recipientIds
      });
      this.set('showChooseReceivers', false);
      return this.setSentState();

    },

    removeRecipient: function(recipientId) {
      let recipient = this.get('recipients').findBy('id', recipientId);
      return this.get('recipients').removeObject(recipient);
    },

    addRecipient: function(newRecipient) {
      const user = this.get('store').findOrPush('user', newRecipient);
      this.get('recipients').addObject(user);
    },

    searchStarted() {
      this.set('searchingParticipant', true);
    },

    searchFinished() {
      this.set('searchingParticipant', false);
    }
  }
});
