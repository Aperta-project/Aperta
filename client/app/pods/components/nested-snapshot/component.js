import Ember from 'ember';

export default Ember.Component.extend({
  snapshot: null,
  classNames: ['snapshot'],

  generalCase: Ember.computed.not('specialCase'),
  specialCase: Ember.computed.or('author', 'figure', 'supportingInfo', 'funder'),

  raw: Ember.computed('snapshot.type', function(){
    let type = this.get('snapshot.type');
    return type == 'text' || type === 'integer';
  }),

  boolean: Ember.computed('snapshot.type', function(){
    return this.get('snapshot.type') === 'boolean';
  }),

  booleanQuestion: Ember.computed('snapshot.value.answer_type', function(){
    return this.get('snapshot.value.answer_type') === 'boolean';
  }),

  question: Ember.computed('snapshot.type', function(){
    return this.get('snapshot.type') === 'question';
  }),

  author: Ember.computed('snapshot.name', function(){
    return this.get('snapshot.name') === 'author';
  }),

  figure: Ember.computed('snapshot.name', function(){
    return this.get('snapshot.name') === 'figure';
  }),

  supportingInfo: Ember.computed('snapshot.name', function(){
    return this.get('snapshot.name') === 'supporting-information-file';
  }),

  funder: Ember.computed('snapshot.name', function(){
    return this.get('snapshot.name') === 'funder';
  })

});
