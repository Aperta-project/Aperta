import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('authors-task', {
  default: {
    title: 'Authors',
    type: 'AuthorsTask',
    completed: false,

    nestedQuestions: [
      {id: 101, ident: 'authors--persons_agreed_to_be_named',     text: 'question: person agreed to be named?'},
      {id: 102, ident: 'authors--authors_confirm_icmje_criteria', text: 'question: authors confirm icmje criteria?'},
      {id: 103, ident: 'authors--authors_agree_to_submission',    text: 'question: authors agree to submission?'}
    ]
  }
});
