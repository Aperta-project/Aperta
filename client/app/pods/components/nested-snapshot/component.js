import Ember from 'ember';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['snapshot'],

  generalCase: Ember.computed.not('specialCase'),
  specialCase: Ember.computed.or(
    'authorsTask', 'figure', 'supportingInfo', 'funder'),

  // General Case
  raw: Ember.computed('snapshot1.type', function(){
    let type = this.get('snapshot1.type');
    return type === 'text' || type === 'integer';
  }),

  boolean: Ember.computed('snapshot1.type', function(){
    return this.get('snapshot1.type') === 'boolean';
  }),

  booleanQuestion: Ember.computed('snapshot1.value.answer_type', function(){
    return this.get('snapshot1.value.answer_type') === 'boolean';
  }),

  question: Ember.computed('snapshot1.type', function(){
    return this.get('snapshot1.type') === 'question';
  }),

  figure: Ember.computed('snapshot1.name', function(){
    return this.get('snapshot1.name') === 'figure-task';
  }),

  authorsTask: Ember.computed('snapshot1.name', function(){
    return this.get('snapshot1.name') === 'authors-task';
  }),

  supportingInfo: Ember.computed('snapshot1.name', function(){
    return this.get('snapshot1.name') === 'supporting-information-task';
  }),

  funder: Ember.computed('snapshot1.name', function(){
    return this.get('snapshot1.name') === 'funder';
  }),

  children: Ember.computed(
    'snapshot1.children',
    'snapshot2.children',
    function(){
      return _.zip(
        this.get('snapshot1.children'),
        this.get('snapshot2.children') || []);
    })
});
