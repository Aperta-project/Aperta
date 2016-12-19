import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  classNameBindings: [
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],


  selectedData: Ember.computed('answer.value', function() {
    const value = this.get('answer.value');
    const id = parseInt(value) || value;
    return this.get('source').findBy('id', id);
  }),

  change(){
    // noop
    // override nested-question component
  },

  actions: {
    selectionSelected(selection) {
      this.set('answer.value', selection.id);
      this.set('answer.additionalData', { nav_customer_number: selection.nav_customer_number });
      this.sendAction('selectionSelected', selection);
      this.save();

      if(this.get('validate')) {
        this.get('validate')(this.get('ident'), selection.id);
      }
    }
  }
});
