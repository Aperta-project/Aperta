import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('reviewer-report-task', {
  default: {
    title: 'Review by Pikachu',
    type: 'ReviewerReportTask',
    completed: false
  },
  traits: {
    with_paper_and_journal: {
      paper: FactoryGuy.belongsTo('paper', 'with_journal')
    },
    with_questions: {
      nestedQuestions(task) {
        return [
          'reviewer_report--additional_comments',
          'reviewer_report--comments_for_author',
          'reviewer_report--competing_interests',
          'reviewer_report--competing_interests--detail',
          'reviewer_report--decision_term',
          'reviewer_report--identity',
          'reviewer_report--suitable_for_another_journal',
          'reviewer_report--suitable_for_another_journal--journal'
        ].map(function(ident) {
          return FactoryGuy.make('nested-question', {owner: task, ident });
        });
      }
    }
  }
});
