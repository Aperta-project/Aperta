import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import Factory from '../helpers/factory';

let App = null;

module('Integration: Feedback Form', {
  afterEach: function() {
    Ember.run(App, 'destroy');
  },

  beforeEach: function() {
    App = startApp();
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/affiliations', status: 304 });

    $.mockjax({
      url: '/api/journals',
      method: 'GET',
      status: 200,
      responseText: { journals: [] }
    });
    $.mockjax({
      url: '/api/feedback',
      method: 'POST',
      status: 201,
      responseText: {}
    });
    $.mockjax({
      url: '/api/countries',
      status: 200,
      responseText: { countries: [{ id: 1, text: 'Peru'}] }
    });
  }
});

test('clicking the feedback button sends feedback', function(assert) {
  Ember.run(function(){
    Factory.createPermission('User', 1, ['view_profile']);

    visit('/profile');
    click('#profile-dropdown-menu');
    click('a:contains(Give Feedback on)');
    fillIn('.overlay textarea', 'My feedback');
    click('.overlay-footer-content .button-primary');

    andThen(function() {
      assert.ok(
        find('.feedback-overlay-thanks').length,
        'Thank you message visible'
      );
    });
  });
});
