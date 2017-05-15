import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  additionalData: DS.attr(),
  value: DS.attr(),

  attachments: DS.hasMany('question-attachment', { async: false }),
  cardContent: DS.belongsTo('card-content', { async: false }),
  owner: DS.belongsTo('answerable', { async: false, polymorphic: true }),
  paper: DS.belongsTo('paper'), //TODO APERTA-8972 consider removing from client

  wasAnswered: Ember.computed('value', function(){
    return Ember.isPresent(this.get('value'));
  })
});
