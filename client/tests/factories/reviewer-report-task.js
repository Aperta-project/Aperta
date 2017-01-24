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
    with_reports: {
      reviewerReports(task) {
        return FactoryGuy.make('reviewer-report', 'with_questions', {task: task});
      }
    }
  }
});
