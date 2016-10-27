import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'author-form',
  'Integration | Component | author-form',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);

      let user = FactoryGuy.make('user');
      let task = FactoryGuy.make('authors-task');
      let author = FactoryGuy.make('author', { user: user });

      this.set('author', author);
      this.set('isNotEditable', false);
      this.set('model', Ember.ObjectProxy.create({object: author}));
      this.set('task', task);

      this.set("toggleEditForm", () => {});
      this.set("validateField", () => {});

      let createQA = (owner, ident, answerValue) => {
        let answer = FactoryGuy.make('nested-question-answer', {value: answerValue, owner: owner});
        let question = FactoryGuy.make('nested-question', {
          ident: ident,
          answers: [answer],
          owner: owner
        });

        owner.get('nestedQuestions').addObject(question);
      };

      createQA(author, 'author--published_as_corresponding_author', true);
      createQA(author, 'author--deceased', false);
      createQA(author, 'author--government-employee', false);
      createQA(author, 'author--contributions--conceptualization', false);
      createQA(author, 'author--contributions--investigation', false);
      createQA(author, 'author--contributions--visualization', false);
      createQA(author, 'author--contributions--methodology', false);
      createQA(author, 'author--contributions--resources', false);
      createQA(author, 'author--contributions--supervision', false);
      createQA(author, 'author--contributions--software', false);
      createQA(author, 'author--contributions--data-curation', false);
      createQA(author, 'author--contributions--project-administration', false);
      createQA(author, 'author--contributions--validation', false);
      createQA(author, 'author--contributions--writing-original-draft', false);
      createQA(author, 'author--contributions--writing-review-and-editing', false);
      createQA(author, 'author--contributions--funding-acquisition', false);
      createQA(author, 'author--contributions--formal-analysis', false);
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
  assert.elementNotFound(".orcid-connect");
});
