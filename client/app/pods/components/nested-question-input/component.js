import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  displayContent: true,
  inputClassNames: ["form-control tall-text-field"],
  wrapInput: true,
  type: 'text',
  willUpdate() {
    this._super(...arguments);
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
      this.get('model').save();
    }
  }
});
