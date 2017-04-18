import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  parentAnswer: Ember.computed('content.parent', 'owner', function() {
    return this.get('content.parent').answerForOwner(this.get('owner'));
  }),

  showChildren: Ember.computed(
    'parentAnswer.value',
    'content.visibleWithParentAnswer',
    function() {
      let parentValue = this.get('parentAnswer.value');
      if (parentValue === null || parentValue === undefined) { return false; }
      return (parentValue).toString() ===
        this.get('content.visibleWithParentAnswer');
    }
  )
});
