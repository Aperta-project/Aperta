import Ember from 'ember';

export default Ember.Component.extend({
  // attrs
  editing: false,
  emailSentStates: null,
  isNew: false,
  isSendable: true,
  item: null,
  overlayParticipants: null
});
