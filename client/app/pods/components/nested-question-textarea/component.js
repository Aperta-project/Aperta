import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
export default NestedQuestionComponent.extend({
  placeholder: null,
  displayContent: true,
  inputClassNames: ['form-control'],

  willUpdate() {
    this._super(...arguments);
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
    }
  }
});
