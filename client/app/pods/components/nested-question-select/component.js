import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  classNameBindings: [
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],

  init: function() {
    this._super(...arguments);
    if (this.get('defaultSelection') && !this.get('model.answer.value')) {
      this.set('selectedData', this.get('defaultSelection'));
      this.sendAction('selectionSelected', this.get('defaultSelection'));
    }
  },

  defaultSelection: null,

  selectedData: Ember.computed('model.answer.value', function() {
    const value = this.get('model.answer.value');
    const id = parseInt(value) || value;
    return this.get('source').findBy('id', id);
  }),

  change(){
    // noop
    // override nested-question component
  },

  actions: {
    selectionSelected(selection) {
      this.set('model.answer.value', selection.id);
      this.set('model.answer.additionalData', { nav_customer_number: selection.nav_customer_number })
      this.sendAction('selectionSelected', selection);
      this.save();

      if(this.attrs.validate) {
        this.attrs.validate(this.get('model.ident'), selection.id);
      }
    }
  }
});
