import Ember from 'ember';

export default Ember.Component.extend({
  // attrs
  allUsers: null,
  block: null,
  editing: false,
  emailSentStates: null,
  isNew: false,
  isSendable: true,
  item: null,
  overlayParticipants: null
});
