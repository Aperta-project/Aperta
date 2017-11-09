import Ember from 'ember';
import { module, test } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';

var app = null;
module('Unit: Author Model', {
  beforeEach: function() {
    app = startApp();
  },
  afterEach: function() {
    Ember.run(app, app.destroy);
  }
});

test('#Affiliations', function(assert) {
  let author = FactoryGuy.make('author', {affiliation: 'ABC', secondAffiliation: null});
  assert.equal(author.get('affiliations'), 'ABC', 'returns the first affiliation without any character appended at the end');
  let author_two = FactoryGuy.make('author', {affiliation: 'QAZ', secondaryAffiliation: 'WSX'});
  assert.equal(author_two.get('affiliations'), 'QAZ, WSX', 'returns both affiliations joined by a comma');
});
