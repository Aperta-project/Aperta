import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import FactoryGuy from "ember-data-factory-guy";

let App = null;

module('Integration: Feedback Form', {
  afterEach: function() {
    Ember.run(App, 'destroy');
  },

  beforeEach: function() {
    App = startApp();
    $.mockjax({url: "/api/affiliations", status: 304 });
    $.mockjax({url: "/api/feedback", method: 'POST', status: 201, responseText: {}});
  }
});

test('clicking the feedback button sends feedback to the backend', function(assert) {
  visit('/profile');
  click('.navigation-toggle');
  click('.navigation-item-feedback');
  fillIn('.overlay textarea', "My feedback");
  click('.overlay-footer-content .button-primary');
  andThen(function() {
    assert.ok(find('.feedback-overlay-thanks').length, 'Thank you message visible');
  });
});
