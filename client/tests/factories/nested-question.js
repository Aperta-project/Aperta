import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('nested-question', {
  default: {
    value_type: 'text',
    text: '',
    owner: null,
    answers: []
  },

  traits: {}
});

export function createQuestionWithAnswer(owner, identOrAttrs, answerValue){
  let answers = [];

  if(answerValue){
    let answer = FactoryGuy.make('nested-question-answer', {
      value: answerValue,
      owner: owner
    });
    answers.push(answer);
  }

  let ident;
  let questionAttrs;
  if (_.isObject(identOrAttrs)) {
    ident = identOrAttrs.ident;
    questionAttrs = identOrAttrs;
  } else {
    ident = identOrAttrs;
    questionAttrs = {ident: ident};
  }

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  if(!question){
    question = FactoryGuy.make('nested-question', questionAttrs);
    owner.get('nestedQuestions').addObject(question);
  }

  question.set('answers', answers);
  return question;
}

export function createQuestion(owner, ident, text){
  let questionText = (text || `This is the question text for ${ident}`);

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  if(!question) {
    question = FactoryGuy.make('nested-question', {ident: ident, owner: owner, text: text});
    owner.get('nestedQuestions').addObject(question);
  }

  question.set('text', questionText);

  owner.get('nestedQuestions').addObject(question);
  return question;
}
