import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import { createCard } from 'tahi/tests/factories/card';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-form',
  'Integration | Component | author-form',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);

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
      let author = FactoryGuy.make('author', { user: user });
      let paper = FactoryGuy.make('paper');

      let authorCard = createCard('Author');

      this.set('author', author);
      this.set('author.paper', paper);
      this.set('author.paper.journal', 1);
      this.set('isNotEditable', false);
      this.set('model', Ember.ObjectProxy.create({object: author}));

      this.set("toggleEditForm", () => {});
      this.set("validateField", () => {});
      this.set("canRemoveOrcid", true);
    }
  }
);

var template = hbs`
  {{author-form
      author=model.object
      authorProxy=model
      validateField=(action validateField)
      hideAuthorForm="toggleEditForm"
      isNotEditable=isNotEditable
      saveSuccess=(action toggleEditForm)
      canRemoveOrcid=true
      authorIsPaperCreator=true
  }}`;

test("component displays the orcid-connect component when the author has an orcidAccount", function(assert){
  let orcidAccount = FactoryGuy.make('orcid-account');
  Ember.run( () => {
    this.get("author.user").set("orcidAccount", orcidAccount);
  });
  this.render(template);
  assert.elementFound(".orcid-connect");
});

test("component does not display the orcid-connect component when the author does not have an orcidAccount", function(assert){
  Ember.run( () => {
    this.get("author.user").set("orcidAccount", null);
  });
  this.render(template);
  assert.elementNotFound(".orcid-wrapper");
});
