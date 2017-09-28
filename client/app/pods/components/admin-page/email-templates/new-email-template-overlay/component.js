import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    journal: PropTypes.EmberObject,
    success: PropTypes.func, // action, called when card is created
    close: PropTypes.func // action, called to close the overlay
  },

  classNames: ['admin-overlay'],
  name: '',
  scenario: '',
  errors: null,
  scenarioError: Ember.computed('errors', function() {
    return this.get('errors') && this.get('errors').has('scenario') ? 'labeled-input-with-errors-errored' : null;
  }),
  templateNames: Ember.computed('templates[]', function() {
    if (this.get('templates.length')) {
      return this.get('templates').mapBy('name');
    } else {
      return [];
    }
  }),

  store: Ember.inject.service(),

  actions: {
    close() {
      this.get('close')();
    },

    complete() {
      this.set('errors', null);
      const template = this.get('store').createRecord('letter-template', {
        name: this.get('name'),
        journalId: this.get('journal.id'),
        scenario: this.get('scenario.name'),
        mergeFields: this.get('scenario.merge_fields')
      });

      let errors = template.get('errors');
      if (Ember.isBlank(this.get('scenario'))) errors.add('scenario', 'This field is required');

      let name = this.get('name');
      if (Ember.isBlank(name)) errors.add('name', 'This field is required');
      if (this.get('templateNames').map(n => n.toLowerCase()).includes(name.toLowerCase())) {
        errors.add('name', 'That template name is taken for this journal. Please give your template a new name.');
      }

      if (template.get('errors.isEmpty')) {
        this.get('success')(template);
        this.get('close')();
      } else {
        this.set('errors', errors);
      }
    },

    valueChanged(newVal) {
      this.set('scenario', newVal);
    }
  }
});
