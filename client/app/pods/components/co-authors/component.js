import Ember from 'ember';

export default Ember.Component.extend({
  date_created: Ember.computed('created_at', function() {
    return moment(this.get('author.created_at')).format('ll');
  }),

  actions: {
    save() {
      this.set('author.confirmationState', 'confirmed');
      this.get('author').save();
    }
  }
});
