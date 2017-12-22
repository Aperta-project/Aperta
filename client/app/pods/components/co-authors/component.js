import Ember from 'ember';
import moment from 'moment';

export default Ember.Component.extend({
  classNames: ['co-author-confirmaion'],
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
