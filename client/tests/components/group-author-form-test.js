import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import FakeCanService from '../helpers/fake-can-service';

import hbs from 'htmlbars-inline-precompile';

let journal;

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

      journal = FactoryGuy.make('journal');
      TestHelper.mockFind('journal').returns({model: journal});

      let user = FactoryGuy.make('user');
      let task = FactoryGuy.make('authors-task');
      let author = FactoryGuy.make('group-author');
      let paper = FactoryGuy.make('paper');

      this.set('author', author);
      this.set('author.paper', paper);
      this.set('author.paper.journal', journal);
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

test("component shows coauthor controls when user is considered an admin user", function(assert){
  // Administrator
  Ember.run(() => {
    const can = FakeCanService.create().allowPermission('administer', journal);
    this.register('service:can', can.asService());
  });

  this.render(template);
  assert.elementFound('[data-test-selector="coauthor-radio-controls"]');
});

test("component hides coauthor controls when user is considered an non-admin user", function(assert){
  // Administrator
  Ember.run(() => {
    const can = FakeCanService.create().rejectPermission('administer', journal);
    this.register('service:can', can.asService());
  });

  this.render(template);
  assert.elementNotFound('[data-test-selector="coauthor-radio-controls"]');
});
