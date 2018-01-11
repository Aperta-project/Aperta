import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  name: DS.attr('string'),
  category: DS.attr('string'),
  to: DS.attr('string'),
  subject: DS.attr('string'),
  body: DS.attr('string'),
  journalId: DS.attr('number'),
  mergeFields: DS.attr(),
  scenario: DS.attr('string'),
  cc: DS.attr('string'),
  bcc: DS.attr('string'),

  subjectErrors: [],
  bodyErrors: [],
  ccErrors: [],
  bccErrors: [],
  nameError: '',

  nameEmpty: Ember.computed.empty('name'),
  subjectErrorPresent: Ember.computed.notEmpty('subjectErrors'),
  bodyErrorPresent: Ember.computed.notEmpty('bodyErrors'),
  nameErrorPresent: Ember.computed.notEmpty('nameError'),
  ccErrorPresent: Ember.computed.notEmpty('ccErrors'),
  bccErrorPresent: Ember.computed.notEmpty('bccErrors'),
  hasErrors: Ember.computed.or('subjectErrorPresent', 'bodyErrorPresent', 'nameErrorPresent', 'ccErrorPresent', 'bccErrorPresent'),

  clearErrors() {
    this.setProperties({
      subjectErrors: [],
      bodyErrors: [],
      ccErrors: [],
      bccErrors: []
    });
  },

  parseErrors(error) {
    const subjectErrors = error.errors.filter((e) => e.source.pointer.includes('subject'));
    const bodyErrors = error.errors.filter((e) => e.source.pointer.includes('body'));
    const nameError = error.errors.filter(e => e.source.pointer.includes('name'));
    const ccErrors = error.errors.filter(e => e.source.pointer.endsWith('/cc'));
    const bccErrors = error.errors.filter(e => e.source.pointer.endsWith('/bcc'));
    if (subjectErrors.length) {
      this.set('subjectErrors', subjectErrors.map(s => s.detail));
    }
    if (bodyErrors.length) {
      this.set('bodyErrors', bodyErrors.map(b => b.detail));
    }
    if (nameError.length) {
      this.set('nameError', nameError.map(n => n.detail));
    }
    if (ccErrors.length) {
      this.set('ccErrors', ccErrors.map(err => err.detail));
    }
    if (bccErrors.length) {
      this.set('bccErrors', bccErrors.map(err => err.detail));
    }
  },

  preview() {
    let data = _.pick(this.serialize(), ['body', 'subject', 'cc', 'bcc']);
    let modelName = this.constructor.modelName;
    let adapter = this.store.adapterFor(modelName);
    return adapter.preview(this.get('id'), data);
  }
});
