import Ember from 'ember';

export default Ember.Component.extend({
  primary: Ember.computed.reads('invitation'),

  queueHasInvitedOrAccepted: Ember.computed('primary.state', 'primary.alternates.@each.state', function(){
    const primaryInvitedOrAccepted = this.invitedOrAccepted(this.get('primary'));
    const altsHaveInvitedOrAccepted = this.get('primary.alternates').any((inv)=> {
      return this.invitedOrAccepted(inv);
    });

    return primaryInvitedOrAccepted || altsHaveInvitedOrAccepted;
  }),

  invitedOrAccepted(obj) {
    return obj.get('state') === 'invited' || obj.get('state') === 'accepted'; 
  }
});