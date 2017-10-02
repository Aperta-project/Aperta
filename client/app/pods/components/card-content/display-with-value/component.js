import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  parentAnswer: Ember.computed('content.parent', 'owner', 'repetition', function() {
    return this.get('content.parent').answerForOwner(this.get('owner'), this.get('repetition'));
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
  ),

  pruneOldAnswers: Ember.observer('showChildren', function() {
    if(this.get('preview')) { return; }
    if(this.get('showChildren')) { return; }

    let owner = this.get('owner');
    let content = this.get('content');
    let repetition = this.get('repetition');

    content.destroyDescendants(owner, repetition);
  }),
});
