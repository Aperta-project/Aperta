import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import FactoryGuy from "ember-data-factory-guy";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App = null;

module('Integration: Feedback Form', {
  afterEach: function() {
    Ember.run(function() {
      TestHelper.teardown();
      App.destroy();
    });
  },

  beforeEach: function() {
    App = startApp();
    TestHelper.setup(App);
    $.mockjax({url: "/api/admin/journals/authorization", status: 204});
    $.mockjax({url: "/api/user_flows/authorization", status: 204});
    $.mockjax({url: "/api/feedback", method: 'POST', status: 201, responseText: {}});

    // NOTE: We don't care about having data on the page when testing the feedback form
    TestHelper.handleFindAll('journal', 0);
    TestHelper.handleFindAll('paper', 0);
    TestHelper.handleFindAll('invitation', 0);
    TestHelper.handleFindAll('comment-look', 0);
  }
});

test('clicking the feedback button sends feedback to the backend', function(assert) {
  visit('/');
  click('.navigation-toggle');
  click('.navigation-item-feedback');
  fillIn('.overlay textarea', "My feedback");
  click('.overlay-footer-content .button-primary');
  andThen(function() {
    assert.ok(Ember.isPresent(find('.feedback-overlay-thanks')), 'Thank you message visible');
  });
});

test('Regression: Opening new paper overlay then feedback overlay shows feedback overflay', function(assert) {
  visit('/');
  click('.button-primary:contains(Create New Submission)');
  click('.overlay-close-x');
  click('.navigation-toggle');
  click('.navigation-item-feedback');
  andThen(function() {
    assert.ok(Ember.isPresent(find('.overlay-container.full.feedback')), 'Feeback overlay visible');
  });
});
