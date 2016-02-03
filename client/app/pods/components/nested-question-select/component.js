import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  selectedData: Ember.computed('model.answer', function() {
    const id = parseInt(this.get('model.answer.value')) || this.get('model.answer.value');
    return this.get('source').findBy('id', id);
  }),

  actions: {
    selectionSelected: function(selection) {
      this.set('model.answer.value', selection.id);
      this.sendAction('selectionSelected', selection);
    }
  }
});
