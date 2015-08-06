import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user', { async: false }),

  country: DS.attr('string'),
  department: DS.attr('string'),
  email: DS.attr('string'),
  endDate: DS.attr('string'),
  name: DS.attr('string'),
  startDate: DS.attr('string'),
  title: DS.attr('string'),
  ringgoldId: DS.attr('string'),

  isCurrent: Ember.computed('endDate', function() {
    return Ember.isBlank(this.get('endDate'));
  })
});
