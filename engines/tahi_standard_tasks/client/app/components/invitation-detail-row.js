import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: 'invitation',

  invitation: null,
  destroyAction: null,

  invitee: Ember.computed.alias('invitation.invitee'),

  canDestroy: Ember.computed.notEmpty('destroyAction'),
  invitationNotAccepted: Ember.computed.not('invitation.accepted'),
  displayDestroy: Ember.computed.and('canDestroy', 'invitationNotAccepted')
});
