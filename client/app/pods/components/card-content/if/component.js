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
    this.addObserver(conditionKey, function() {
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
      this.set('conditionValue', value);
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
