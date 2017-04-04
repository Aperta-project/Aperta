import Ember from 'ember';

export default Ember.Component.extend({
  tagName: '',
  owner: null,
  content: null,
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
