import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', {
    polymorphic: true,
    async: false,
  }),
  ident: DS.attr('string'),
  position: DS.attr('number'),
  value_type: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  text: DS.attr('string'),
  children: DS.hasMany('nested-question', { async: false, inverse: 'parent' }),
  parent: DS.belongsTo('nested-question', { async: false }),
  answers: DS.hasMany('nested-question-answer', { async: false , inverse: 'nestedQuestion'}),

  answer: Ember.computed(function(){
    let taskId = this.get('task.id');
    if(!taskId){ return; }

    let answer = this.get('answers').findBy('task.id', taskId);
    if(!answer){
      answer = this.store.createRecord('nested-question-answer', {
        nestedQuestion: this.get('model'),
        task: this.get('task')
      });
      this.get('answers').addObject(answer);
    }
    return answer;
  })
});
