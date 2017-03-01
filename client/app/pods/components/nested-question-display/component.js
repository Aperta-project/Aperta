import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';

export default CardContentQuestion.extend({
  classNameBindings: [
    ':nested-question-display',
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],
  tagName: 'span'
});
