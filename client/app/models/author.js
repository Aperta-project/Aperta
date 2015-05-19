import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),

  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  position: DS.attr('number'),

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName')
});
