import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  classNameBindings: [
    ':nested-question-display',
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],
  tagName: 'span'
});
