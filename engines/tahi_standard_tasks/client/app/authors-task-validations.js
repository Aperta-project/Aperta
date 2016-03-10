
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
