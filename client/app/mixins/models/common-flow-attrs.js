import Ember from 'ember';
import DS from 'ember-data';

export default Ember.Mixin.create({
  papers: DS.hasMany('paper', { async: false }),
  tasks: DS.hasMany('card-thumbnail', { async: false }),
  title: DS.attr('string'),
  flowId: DS.attr('number'),
  taskRoles: DS.attr()
});
