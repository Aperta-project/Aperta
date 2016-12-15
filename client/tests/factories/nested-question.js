import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("nested-question", {
  default: {
    value_type: "text",
    text: '',
    owner: null
  },

  traits: {}
});

export function createQuestionWithAnswer(owner, ident, answerValue){
  let answers = [];

  if(answerValue){
    let answer = FactoryGuy.make('nested-question-answer', {
      value: answerValue,
      owner: owner
    });
    answers.push(answer);
  }

  let question = FactoryGuy.make('nested-question', {
    ident: ident,
    answers: answers,
    owner: owner
  });

  owner.get('nestedQuestions').addObject(question);
  return question;
}

export function createQuestion(owner, ident, text){
  let questionText = (text || `This is the question text for ${ident}`);
  let question = FactoryGuy.make('nested-question', {
    ident: ident,
    owner: owner,
    text: questionText,
    answers: []
  });

  owner.get('nestedQuestions').addObject(question);
  return question;
}
