import Ember from 'ember';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  nestedLevel: 1,
  classNames: ['snapshot'],
  classNameBindings: ['levelClassName'],

  generalCase: Ember.computed.not('specialCase'),
  specialCase: Ember.computed.or(
    'authorsTask', 'figure', 'supportingInfo', 'funder'),

  authorsTask: Ember.computed.equal('snapshot1.name', 'authors-task'),
  boolean: Ember.computed.equal('snapshot1.type', 'boolean'),
  booleanQuestion: Ember.computed.equal(
    'snapshot1.value.answer_type',
    'boolean'),
  figure: Ember.computed.equal('snapshot1.name', 'figure-task'),
  funder: Ember.computed.equal('snapshot1.name', 'funder'),
  id: Ember.computed.equal('snapshot1.name', 'id'),
  integer: Ember.computed.equal('snapshot1.type', 'integer'),
  question: Ember.computed.equal('snapshot1.type', 'question'),
  supportingInfo: Ember.computed.equal(
    'snapshot1.name',
    'supporting-information-task'),
  text: Ember.computed.equal('snapshot1.type', 'text'),
  text_or_integer: Ember.computed.or('integer', 'text'),
  userEnteredValue: Ember.computed.not('id'),

  raw: Ember.computed('snapshot1.type', function(){
    return this.get('text_or_integer') && this.get('userEnteredValue');
  }),

  children: Ember.computed(
    'snapshot1.children',
    'snapshot2.children',
    function(){
      return _.zip(
        this.get('snapshot1.children'),
        this.get('snapshot2.children') || []);
    }
  ),

  levelClassName: Ember.computed('nestedLevel', function(){
    return `nested-level-${this.get('nestedLevel')}`;
  }),

  incrementedNestedLevel: Ember.computed('nestedLevel', function(){
    return this.incrementProperty('nestedLevel');
  }),
});
