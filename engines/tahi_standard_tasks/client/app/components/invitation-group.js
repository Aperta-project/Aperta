import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

let errorText = 'There was a problem saving your invitation. Please refresh.';

export default Ember.Component.extend({
  flash: Ember.inject.service(),

  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  positionSort: ['position:asc'],
  sortedInvitations: Ember.computed.sort('invitations', 'positionSort'),

  invitationsInFlight: Ember.computed('invitations.@each.isSaving', function() {
    return this.get('invitations').isAny('isSaving');
  }),

  changePosition: concurrencyTask(function * (newPosition, invitation) {
    try {
      return yield invitation.changePosition(newPosition);
    } catch (e) {
      this.get('flash').displayRouteLevelMessage('error', errorText);
    }
  }).drop(),

  actions: {
    changePosition(newPosition, invitation) {

      let sorted = this.get('sortedInvitations');

      sorted.removeObject(invitation);
      sorted.insertAt(newPosition - 1, invitation);
      this.get('changePosition').perform(newPosition, invitation);
    },

    displayError() {
      this.get('flash').displayRouteLevelMessage('error', errorText);
    }
  }
});
