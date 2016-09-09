import Ember from 'ember';
import SnapshotAttachment from 'tahi/models/snapshot/attachment';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  nestedLevel: 1,
  classNames: ['snapshot'],
  classNameBindings: ['levelClassName'],

  primarySnapshot: Ember.computed('snapshot1', 'snapshot2', function(){
    return (this.get('snapshot1') || this.get('snapshot2'));
  }),
  generalCase: Ember.computed.not('specialCase'),
  specialCase: Ember.computed.or(
    'authorsTask', 'funder', 'coverLetterTask'),

  authorsTask: Ember.computed.equal('primarySnapshot.name', 'authors-task'),
  coverLetterTask: Ember.computed.equal('primarySnapshot.name', 'cover-letter-task'),
  boolean: Ember.computed.equal('primarySnapshot.type', 'boolean'),
  booleanQuestion: Ember.computed.equal(
    'primarySnapshot.value.answer_type',
    'boolean'),
  figure: Ember.computed.equal('primarySnapshot.name', 'figure'),
  supportingInformationFile: Ember.computed.equal('primarySnapshot.name', 'supporting-information-file'),
  file1: Ember.computed('snapshot1', function() {
    return SnapshotAttachment.create({attachment: this.get('snapshot1')});
  }),
  file2: Ember.computed('snapshot2', function() {
    return SnapshotAttachment.create({attachment: this.get('snapshot2')});
  }),
  funder: Ember.computed.equal('primarySnapshot.name', 'funder'),
  id: Ember.computed.equal('primarySnapshot.name', 'id'),
  integer: Ember.computed.equal('primarySnapshot.type', 'integer'),
  question: Ember.computed.equal('primarySnapshot.type', 'question'),
  supportingInfo: Ember.computed.equal(
    'primarySnapshot.name',
    'supporting-information-task'),
  text: Ember.computed.equal('primarySnapshot.type', 'text'),
  textOrInteger: Ember.computed.or('integer', 'text'),
  userEnteredValue: Ember.computed.not('id'),

  hasQuestion1Title: Ember.computed.notEmpty('snapshot1.value.title'),
  hasQuestion2Title: Ember.computed.notEmpty('snapshot2.value.title'),
  diffQuestionTitles: Ember.computed.and('hasQuestion1Title', 'hasQuestion2Title'),

  raw: Ember.computed('primarySnapshot.type', function(){
    return this.get('textOrInteger') && this.get('userEnteredValue');
  }),

  children: Ember.computed(
    'snapshot1.children',
    'snapshot2.children',
    function(){
      return _.zip(
        this.get('snapshot1.children') || [],
        this.get('snapshot2.children') || []);
    }
  ),

  levelClassName: Ember.computed('nestedLevel', function(){
    return `nested-level-${this.get('nestedLevel')}`;
  }),

  incrementedNestedLevel: Ember.computed('nestedLevel', function(){
    return this.incrementProperty('nestedLevel');
  })
});
