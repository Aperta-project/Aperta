import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('paper-reviewer-task', {
  default: {
    title: 'Invite Reviewers',
    type: 'PaperReviewerTask',
    inviteeRole: 'Reviewer',
    completed: false,
  }
});
