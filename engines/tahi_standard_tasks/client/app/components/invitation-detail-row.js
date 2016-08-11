import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: 'invitation',
  propTypes: {
    invitation: PropTypes.EmberObject.isRequired,
    destroyAction: PropTypes.func.isRequired,
    editAction: PropTypes.func
  },

  invitee: Ember.computed.alias('invitation.invitee'),
  displayDestroy: Ember.computed.not('invitation.accepted'),
  displayEdit: Ember.computed.and('invitation.pending', 'editAction')
});
