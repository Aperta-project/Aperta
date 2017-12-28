import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['co-author-confirmation'],
  isConfirmed: Ember.computed.equal('author.confirmationState', 'confirmed'),
  isConfirmable: Ember.computed.equal('author.confirmationState', 'unconfirmed'),

  PropTypes: {
    author: PropTypes.EmberObject.isRequired
  },

  actions: {
    save() {
      this.set('author.confirmationState', 'confirmed');
      this.get('author').save();
    }
  }
});
