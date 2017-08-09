import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import findNearestProperty from 'tahi/lib/find-nearest-property';

export default Ember.Component.extend({
  classNames: ['card-content-if'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  scenario: null,
  computedScenario: Ember.computed(function () {
    return findNearestProperty(this, 'scenario');
  }),

  init() {
    this._super(...arguments);
    if (!this.get('preview')) {
      let conditionName = this.get('conditionName');
      let conditionKey = `computedScenario.${conditionName}`;
      this.getConditionValue();
      this.addObserver(conditionKey, function() {
        Ember.run(() => {
          this.getConditionValue();
        });
      });
    }
  },

  getConditionValue() {
    let conditionName = this.get('conditionName');
    let scenario = this.get('computedScenario');
    let value = Ember.get(scenario, conditionName);
    this.set('conditionValue', value);
  },

  previewState: true,
  conditionName: Ember.computed.reads('content.condition'),
  conditionValue: null,

  condition: Ember.computed(
    'content.condition',
    'preview',
    'previewState',
    'conditionValue',
    function() {
      if (this.get('preview')) {
        return this.get('previewState');
      } else {
        return this.get('conditionValue');
      }
    }
  )
});
