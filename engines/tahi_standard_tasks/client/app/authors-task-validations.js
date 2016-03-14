export const contributionIdents = [
  'author--contributions--conceptualization',
  'author--contributions--investigation',
  'author--contributions--visualization',
  'author--contributions--methodology',
  'author--contributions--resources',
  'author--contributions--supervision',
  'author--contributions--software',
  'author--contributions--data-curation',
  'author--contributions--project-administration',
  'author--contributions--validation',
  'author--contributions--writing-original-draft',
  'author--contributions--writing-review-and-editing',
  'author--contributions--funding-acquisition',
  'author--contributions--formal-analysis',
];

export const acknowledgementIdents = [
  'authors--persons_agreed_to_be_named',
  'authors--authors_confirm_icmje_criteria',
  'authors--authors_agree_to_submission',
];

export const taskValidations = {
  'acknowledgements': [{
    type: 'equality',
    message: 'Please acknowledge the statements below',
    validation() {
      const author = this.get('task');

      return _.every(acknowledgementIdents, (ident) => {
        return author.answerForQuestion(ident).get('value');
      });
    }
  }]
};

// This set of validations is used for each Author model

export default {
  'firstName': ['presence'],
  'lastName': ['presence'],
  'authorInitial': ['presence'],
  'email': ['presence', 'email'],
  'affiliation': ['presence'],
  'government': [{
    type: 'presence',
    message: 'A selection must be made',
    validation() {
      const author = this.get('object');
      const answer = author.answerForQuestion('author--government-employee')
                           .get('value');

      return answer === true || answer === false;
    }
  }],
  'contributions': [{
    type: 'presence',
    message: 'One must be selected',
    validation() {
      const author = this.get('object');

      return _.some(contributionIdents, (ident) => {
        return author.answerForQuestion(ident).get('value');
      });
    }
  }]
};
