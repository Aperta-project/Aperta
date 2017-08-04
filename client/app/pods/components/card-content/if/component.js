import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-if'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
    // It seems like this component needs to receive the 'scenario',
    // and then forward it down to its children
  },

  previewState: true,
  conditionName: Ember.computed.reads('content.condition'),

  condition: Ember.computed(
    'content.condition',
    'preview',
    'previewState',
    'owner.completed',
    'disabled',
    function() {
      if (this.get('preview')) {
        return this.get('previewState');
      } else {
        let conditionName = this.get('conditionName');
        return this.get(conditionName);
      }
    }
  )
});
