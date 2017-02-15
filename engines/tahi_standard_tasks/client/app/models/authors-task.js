import Ember from 'ember';
import Task from 'tahi/models/task';

export default Task.extend({
  fetchRelationships() {
    return Ember.RSVP.all([
      this._super(...arguments),
      this.get('store').queryRecord('card', { name: 'Author' }),
      this.get('store').queryRecord('card', { name: 'GroupAuthor' })
    ]);
  }
});
