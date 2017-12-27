import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['co-author-confirmation'],
  isConfirmed: Ember.computed.equal('author.confirmationState', 'confirmed'),
  isConfirmable: Ember.computed.equal('author.confirmationState', 'unconfirmed'),

  actions: {
    save() {
      this.set('author.confirmationState', 'confirmed');
      this.get('author').save();
    }
  }
});
