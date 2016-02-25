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

export default {
  'firstName': ['presence'],
  'lastName': ['presence'],
  'email': ['presence', 'email'],
  'title': ['presence'],
  'department': ['presence'],
  'affiliation': ['presence'],
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
