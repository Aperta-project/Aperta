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
  bivalent: Ember.computed.equal('content.children.length', 2),
  computedScenario: Ember.computed(function() {
    return findNearestProperty(this, 'scenario');
  }),

  /**
   * The 'if' component will look up a given key on the 'scenario' that is passed to it.
   * We can't statically know the value of the that key, we can't use a standard computed property.
   * One option is to use 'this.defineProperty' to define a computed property in init() with a dynamic key.
   * The other option is to use an observer. In this case I thought that the observer-based implementation would be
   * easier to reason about and require less ember knowledge than using 'defineProperty'
   */
  init() {
    this._super(...arguments);
    let preview = this.get('preview');
    if (!preview) {
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
