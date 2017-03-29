import Ember from 'ember';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  card: null,
  classNames: ['card-editor-name-container'],
  cardName: Ember.computed.alias('card.name'),

  editing: false,
  saving: Ember.computed.reads('saveCard.isRunning'),
  errors: null,

  saveCard: task(function * () {
    const card = this.get('card');
    this.clearErrors();

    card.set('name', this.get('cardName'));

    try {
      yield card.save();
      this.set('editing', false);
    } catch (e) {
      this.set('errors', card.get('errors'));
    }
  }),

  clearErrors() {
    this.set('errors', null);
  },

  actions: {
    edit() {
      this.set('editing', true);
    },

    cancel() {
      this.set('editing', false);
      this.get('card').rollbackAttributes();
      this.clearErrors();
    },

    complete() {
      this.get('saveCard').perform();
    }
  }
});
