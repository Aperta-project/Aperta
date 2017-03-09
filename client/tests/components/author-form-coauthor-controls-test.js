import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-form-coauthor-controls',
  'Integration | Component | author-form-coauthor-controls',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
      let journal = FactoryGuy.make('journal');
      TestHelper.mockFind('journal').returns({model: journal});
      //
      let user = FactoryGuy.make('user');
      let author = FactoryGuy.make('author', { user: user });
      let paper = FactoryGuy.make('paper');
      //
      this.set('author', author);
      this.set('author.paper', paper);
      this.set('author.paper.journal', 1);
      this.set('isNotEditable', false);
      this.set('actions', { selectAuthorConfirmation: (status) => {
        this.set('selectedStatus', status);
      }});

    }
  }
);

var template = hbs`
  {{author-form-coauthor-controls
          author=author
          disabled=isNotEditable
          setConfirmation=(action "selectAuthorConfirmation")
  }}`;

test("component shows author is confirmed", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'confirmed');
  });
  this.render(template);
  assert.textPresent('.author-confirmed', 'Authorship has been confirmed');
});

test("component shows author is refuted", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'refuted');
  });
  this.render(template);
  assert.textPresent('.author-refuted', 'Authorship has been refuted');
});

test("component shows author is unconfirmed", function(assert) {
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'unconfirmed');
  });
  this.render(template);
  const expectedMessage = 'When you submit your manuscript, an email will be sent to this coauthor at the address you provide below to confirm authorship';

  assert.textPresent('.author-coauthor-info', expectedMessage);
});

test("clicking the radio buttons fire an action with the radio button value", function(assert) {
  assert.expect(3);
  this.render(template);

  this.$("[data-test-selector='confirm-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'confirmed');
  this.$("[data-test-selector='refute-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'refuted');
  this.$("[data-test-selector='unconfirm-authorship']").click();
  assert.equal(this.get('selectedStatus'), 'unconfirmed');
});
