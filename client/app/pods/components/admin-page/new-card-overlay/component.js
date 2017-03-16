import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    journal: PropTypes.EmberObject,
    success: PropTypes.func, // action, called when card is created
    close: PropTypes.func // action, called to close the overlay
  },

  classNames: ['admin-new-card-overlay'],
  cardName: '',
  saving: Ember.computed.reads('createCard.isRunning'),
  errors: null,

  store: Ember.inject.service(),

  createCard: task(function * () {
    this.set('errors', null);
    const card = this.get('store').createRecord('card', {
      name: this.get('cardName'),
      journal: this.get('journal')
    });

    try {
      yield card.save();
      this.get('success')(card);
      this.get('close')();
    } catch (e) {
      this.set('errors', card.get('errors'));
    }
  }),

  actions: {
    close() {
      this.get('close')();
    },

    complete() {
      this.get('createCard').perform();
    }
  }
});
