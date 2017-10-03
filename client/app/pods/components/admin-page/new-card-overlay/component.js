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

  classNames: ['admin-overlay'],
  store: Ember.inject.service(),
  cardName: '',
  cardTaskType: null,
  cardTaskTypes: Ember.computed.reads('journal.cardTaskTypes'),
  saving: Ember.computed.reads('createCard.isRunning'),
  errors: null,

  init() {
    this._super(...arguments);
    this.get('cardTaskTypes').then((ctts) => {
      this.set('cardTaskType', ctts.findBy('taskClass', 'CustomCardTask'));
    });
  },


  createCard: task(function * () {
    this.set('errors', null);
    const card = this.get('store').createRecord('card', {
      name: this.get('cardName'),
      cardTaskType: this.get('cardTaskType'),
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

  didReceiveAttrs(){
    //Defaults the dropdown as the first element in the card list
    this.set('cardTaskType', this.get('cardTaskTypes')[0]);
  },

  actions: {
    close() {
      this.get('close')();
    },

    complete() {
      this.get('createCard').perform();
    },

    valueChanged(newVal) {
      this.set('cardTaskType', newVal);
    }
  }
});
