import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-view',
  'Integration | Component | author-view',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);

      $.mockjax({url: '/api/countries', status: 200, responseText: {
        countries: [],
      }});
      $.mockjax({url: '/api/institutional_accounts', status: 200, responseText: {
        institutional_accounts: [],
      }});

      let authorsTask = FactoryGuy.make('authors-task');
      let author = FactoryGuy.make('author');
      let user = FactoryGuy.make('user');

      author.set('displayName', 'Bob Smith');

      this.set('author', author);
      this.set('currentUser', user);
      this.set('isEditable', true);
      this.set('isNotEditable', false);
      this.set('model', {object: author});
      this.set('task', authorsTask);
    }
  }
);

var template = hbs`
  {{
    author-view
      currentUser=currentUser
      task=task
      model=model
      isEditable=isEditable
      isNotEditable=isNotEditable
      delete="removeAuthor"
  }}`;

test("component lists the author", function(assert){
  this.render(template);

  assert.textPresent('.author-task-item-view .author-name', 'Bob Smith');
  assert.textNotPresent('.author-task-item-view .author-name', '(you)');
});

test("component lists the author when they are the current user", function(assert){
  Ember.run( () => {
    this.get('author').set('user', this.get('currentUser'));
  });
  this.render(template);
  assert.textPresent('.author-task-item-view .author-name', 'Bob Smith (you)');
});

test("component shows author is unconfirmed", function(assert){
  this.render(template);
  // The author's name should be the only text present
  assert.textPresent('[data-test-selector="author-task-item-view-text"]', 'Bob Smith');
});

test("component shows author is confirmed", function(assert){
  Ember.run( () => {
    this.get('author').set('coAuthorState', 'confirmed');
  });
  this.render(template);
  assert.textPresent('[data-test-selector="author-confirmed"]', 'Confirmed');
});

test("component shows author is refuted", function(assert){
  Ember.run( () => {
    this.get('author').set('coAuthorState', 'refuted');
  });
  this.render(template);
  assert.textPresent('[data-test-selector="author-refuted"]', 'Refuted');
});
