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

test('#fullNameWithAffiliations', function(assert) {
  let author = FactoryGuy.make('author', {affiliation: 'ABC', secondAffiliation: null});
  assert.equal(author.get('fullNameWithAffiliations'), `${author.get('displayName')}, ABC`, 'returns full name with affiliations when the latter exist');
  let author_two = FactoryGuy.make('author');
  assert.equal(author_two.get('fullNameWithAffiliations'), `${author_two.get('displayName')}`, 'returns only full name if author does not have affiliations');
});
