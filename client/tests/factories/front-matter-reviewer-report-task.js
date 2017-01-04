import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('front-matter-reviewer-report-task', {
  default: {
    title: 'Review by Pikachu',
    type: 'FrontMatterReviewerReportTask',
    completed: false
  },
  traits: {
    with_paper_and_journal: {
      paper: FactoryGuy.belongsTo('paper', 'with_journal')
    },
    with_questions: {
      nestedQuestions(task) {
        return [
          'front_matter_reviewer_report--additional_comments',
          'front_matter_reviewer_report--competing_interests',
          'front_matter_reviewer_report--decision_term',
          'front_matter_reviewer_report--identity',
          'front_matter_reviewer_report--includes_unpublished_data',
          'front_matter_reviewer_report--includes_unpublished_data--explanation',
          'front_matter_reviewer_report--suitable',
          'front_matter_reviewer_report--suitable--comment'
        ].map(function(ident) {
          return FactoryGuy.make('nested-question', {owner: task, ident });
        });
      }
    }
  }
});
