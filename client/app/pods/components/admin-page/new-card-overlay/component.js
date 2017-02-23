import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    journal: PropTypes.EmberObject,
    close: PropTypes.func // action, called when overlay closes
  },

  classNames: ['admin-new-card-overlay'],
  cardName: '',
  saving: false,
  errors: [],

  store: Ember.inject.service(),

  actions: {
    close() {
      this.get('close')();
    },

    complete() {
      // Create the card, here
      this.set('saving', true);
      this.set('errors', []);
      const card = this.get('store').createRecord('card', {
        name: this.get('cardName'),
        journal: this.get('journal')
      });

      card.save().then(() =>{
        this.set('saving', false);
        this.get('close')();
      }).catch(() => {
        this.set('saving', false);
        this.set('errors', card.get('errors.messages'));
      });
    }
  }
});
