export const contributionIdents = [
  'author--contributions--conceived_and_designed_experiments',
  'author--contributions--performed_the_experiments',
  'author--contributions--analyzed_data',
  'author--contributions--contributed_tools',
  'author--contributions--contributed_writing'
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
      const idents = contributionIdents.concat(
        ['author--contributions--other']
      );

      return _.some(idents, (ident) => {
        return author.answerForQuestion(ident).get('value');
      });
    }
  }]
};
