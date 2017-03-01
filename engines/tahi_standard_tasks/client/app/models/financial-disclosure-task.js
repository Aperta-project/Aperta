import DS from 'ember-data';
import Task from 'tahi/models/task';
import Ember from 'ember';

export default Task.extend({
  funders: DS.hasMany('funder'),
  fetchRelationships() {
    return Ember.RSVP.all([
      this._super(...arguments),
      this.get('store').queryRecord('card', { name: 'TahiStandardTasks::Funder' })
    ]);
  }
});
