import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import FakeCanService from '../helpers/fake-can-service';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'group-author-form',
  'Integration | Component | group-author-form',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
      this.registry.register('service:can', FakeCanService);

      $.mockjax({url: '/api/countries', status: 200, responseText: {
        countries: []
      }});
      $.mockjax({url: '/api/institutional_accounts', status: 200, responseText: {
        institutional_accounts: []
      }});

      let journal = FactoryGuy.make('journal');
      TestHelper.mockFind('journal').returns({model: journal});

      let user = FactoryGuy.make('user');
      let task = FactoryGuy.make('authors-task');
      let author = FactoryGuy.make('group-author');
      let paper = FactoryGuy.make('paper');

      this.set('author', author);
      this.set('author.paper', paper);
      this.set('author.paper.journal', 1);
      this.set('isNotEditable', false);
      this.set('model', Ember.ObjectProxy.create({object: author}));
      this.set('task', task);

      this.set("validateField", () => {});
      this.set("canRemoveOrcid", true);
      this.set('can', FakeCanService.create());

      createQuestionWithAnswer(author, 'author--published_as_corresponding_author', true);
      createQuestionWithAnswer(author, 'author--deceased', false);
      createQuestionWithAnswer(author, 'author--government-employee', false);
      createQuestionWithAnswer(author, 'author--contributions--conceptualization', false);
      createQuestionWithAnswer(author, 'author--contributions--investigation', false);
      createQuestionWithAnswer(author, 'author--contributions--visualization', false);
      createQuestionWithAnswer(author, 'author--contributions--methodology', false);
      createQuestionWithAnswer(author, 'author--contributions--resources', false);
      createQuestionWithAnswer(author, 'author--contributions--supervision', false);
      createQuestionWithAnswer(author, 'author--contributions--software', false);
      createQuestionWithAnswer(author, 'author--contributions--data-curation', false);
      createQuestionWithAnswer(author, 'author--contributions--project-administration', false);
      createQuestionWithAnswer(author, 'author--contributions--validation', false);
      createQuestionWithAnswer(author, 'author--contributions--writing-original-draft', false);
      createQuestionWithAnswer(author, 'author--contributions--writing-review-and-editing', false);
      createQuestionWithAnswer(author, 'author--contributions--funding-acquisition', false);
      createQuestionWithAnswer(author, 'author--contributions--formal-analysis', false);
    }
  }
);

var template = hbs`
  {{group-author-form
      author=model.object
      authorProxy=model
      validateField=(action validateField)
      hideAuthorForm="toggleGroupAuthorForm"
      isNotEditable=isNotEditable
      authorIsPaperCreator=true
  }}`;

test("component shows author is confirmed", function(assert){
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'confirmed');
  });
  this.render(template);
  assert.textPresent('.author-confirmed', 'Authorship has been confirmed');
});

test("component shows author is refuted", function(assert){
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'refuted');
  });
  this.render(template);
  assert.textPresent('.author-refuted', 'Authorship has been refuted');
});

test("component shows author is unconfirmed", function(assert){
  Ember.run( () => {
    this.get("author").set("coAuthorState", 'unconfirmed');
  });
  this.render(template);
  const expectedMessage = 'When you submit your manuscript, an email will be sent to this coauthor at the address you provide below to confirm authorship';

  assert.textPresent('.author-coauthor-info', expectedMessage);
});
