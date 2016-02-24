import {
  moduleForComponent,
  test
} from 'ember-qunit';

import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';
import hbs from 'htmlbars-inline-precompile';

const validations = {
  'email': ['email'],
};

moduleForComponent('author-view', 'AuthorViewComponent', {
  integration: true,

  beforeEach() {
    this.setProperties({
      authorWithErrors: ObjectProxyWithErrors.create({
        object: {
          id: 1,
          answerForQuestion() { return null; },
          findQuestion() {
            return {
              answerForOwner() { return {}; }
            };
          }
        },
        validations: validations
      }),
      isEditable: true,
      isNotEditable: false
    });

    this.actions = {
      removeAuthor() {},
      save() {}
    };
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{author-view isEditable=isEditable
                  isNotEditable=isNotEditable
                  model=authorWithErrors}}
  `);

  assert.equal(this.$('.author-task-item').length, 1, 'element found');
});

test('validation works', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{author-view isEditable=isEditable
                  isNotEditable=isNotEditable
                  model=authorWithErrors}}
  `);

  Ember.run(this, function() {
    this.$('.author-task-item-view-text').click();
    this.$('.author-email').focus().val('invalid.com');
    this.$('.author-first').focus();
  });

  Ember.run(this, function() {
    assert.equal(this.$('.error').length, 1, 'error found');
  });

  Ember.run(this, function() {
    this.$('.author-email').focus().val('valid@test.com');
    this.$('.author-first').focus();
    this.$('.button-secondary').click();
  });

  Ember.run(this, function() {
    assert.equal(this.$('.author-email').text().trim(), 'valid@test.com', 'email found');
  });
});
