import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  store: Ember.inject.service(),
  journal: null,
  complete: null, // action, called when card created
  close: null, // action, called when canceled
  classNames: ['admin-new-card-overlay'],
  cardName: '',
  saving: false,
  errors: [],

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
        this.get('create')(card);
        this.get('complete')();
      }).catch(() => {
        this.set('saving', false);
        this.set('errors', card.get('errors.messages'));
      });
    }
  }
});
