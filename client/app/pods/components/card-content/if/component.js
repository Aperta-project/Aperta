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

  previewState: true,
  conditionName: Ember.computed.reads('content.condition'),
  conditionValue: null,
  scenario: this,

  init() {
    this._super(...arguments);
    let conditionName = this.get('conditionName');
    let conditionKey = `scenario.${conditionName}`;
    this.setConditionValue();
    // window.console.log('Observing', conditionKey);
    this.addObserver(conditionKey, function() {
      // window.console.log('Changing', conditionKey);
      Ember.run(() => {
        this.setConditionValue();
      });
    });
  },

  setConditionValue() {
    let conditionName = this.get('conditionName');
    let scenario = findNearestProperty(this, 'scenario');
    if (scenario) {
      let value = Ember.get(scenario, conditionName);
      // window.console.log('Update', conditionName, value);
      this.set('conditionValue', value);
    } else {
      // window.console.log('No scenario found for', conditionName);
    }
  },

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
