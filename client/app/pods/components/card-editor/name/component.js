import Ember from 'ember';

export default Ember.Component.extend({
  card: null,
  classNames: ['card-editor-name-container'],
  cardName: Ember.computed.alias('card.name'),

  editing: false,
  saving: false,
  errors: null,

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
      const card = this.get('card');

      this.set('saving', true);
      this.clearErrors();

      card.set('name', this.get('cardName'));

      card.save().then(() =>{
        this.set('saving', false);
        this.set('editing', false);
      }).catch(() => {
        this.set('saving', false);
        this.set('errors', card.get('errors'));
      });
    }
  }
});
