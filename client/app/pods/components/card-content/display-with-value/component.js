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

  shouldHide: Ember.observer('parentAnswer.value', function() {
    Ember.run.once(this, 'revertChildrenAnswers');
  }),

  revertChildrenAnswers() {
    if (this.get('content.revertChildrenOnHide') && !this.get('showChildren')) {
      Ember.A(this.get('content.children')).forEach((child) => {
        child.answerForOwner(this.get('owner')).set('value', child.get('defaultAnswerValue'));
      });
    }
  },

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
