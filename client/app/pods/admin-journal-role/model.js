import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  name: DS.attr('string'),
  assignedToTypeHint: DS.attr('string'),
  cardPermissions: DS.hasMany('card-permission'),

  selectItem: Ember.computed('id', 'name', function() {
    return {
      id: this.get('id'),
      text: this.get('name')
    };
  })
});
