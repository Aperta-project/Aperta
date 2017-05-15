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
    }
  }
});
