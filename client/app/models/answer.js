import Ember from 'ember';
import DS from 'ember-data';
import Readyable from 'tahi/mixins/models/readyable';

export default DS.Model.extend(Readyable, {
  additionalData: DS.attr(),
  value: DS.attr(),

  attachments: DS.hasMany('question-attachment', { async: false }),
  cardContent: DS.belongsTo('card-content', { async: false }),
  owner: DS.belongsTo('answerable', { async: false, polymorphic: true }),
  paper: DS.belongsTo('paper'), //TODO APERTA-8972 consider removing from client
  toggleableHideValue: DS.attr('boolean'),

  wasAnswered: Ember.computed('value', function(){
    return Ember.isPresent(this.get('value'));
  })
});
