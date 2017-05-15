import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('reviewer-report', {
  default: {
    task: { id: 1 },
    decision: { id: 1},
    user: { id: 1}
  },
  traits: {
    with_questions: {
      nestedQuestions(report) {
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
          return FactoryGuy.make('nested-question', {owner: report, ident });
        });
      }
    },
    with_front_matter_questions: {
      nestedQuestions(report) {
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
          return FactoryGuy.make('nested-question', {owner: report, ident });
        });
      }
    }
  }
});
