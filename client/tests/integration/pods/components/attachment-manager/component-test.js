import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';

moduleForComponent('attachment-manager', 'Integration | Component | attachment-manager', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    this.setProperties({
      content: Ember.Object.create({
        allowFileCaptions: true,
        allowMultipleUploads: true,
        label: 'Upload',
        text: 'Please upload a file'
      }),
      answer: Ember.Object.create({ value: null, attachments: [] }),
      acceptedFileTypes: ['png', 'tif'],
      disabled: false,
    });
    manualSetup(this.container);
  }
});

let template = hbs`{{attachment-manager
                      filePath="tasks/attachment"
                      attachments=answer.attachments
                      buttonText=content.label
                      description=content.text
                      multiple=content.allowMultipleUploads
                      hasCaption=content.allowFileCaptions
                    }}`;

test(`shows a full attachment manager`, function(assert) {
  this.render(template);
  assert.elementFound('.attachment-manager',
    'element was rendered');
  assert.elementFound('.fileinput-button',
    'has a file input button');
});

test(`displays attachments and has proper action buttons`, function(assert) {
  let attachment = FactoryGuy.make('question-attachment');
  var newReadyIssues = ['incorrect', 'wrong'];

  this.get('answer.attachments').push(attachment);
  this.render(template);

  assert.elementFound('.attachment-item',
    'has an attachment item');
  assert.elementFound('.attachment-item .replace-attachment',
    'has a replacement button');
  assert.elementFound('.attachment-item .delete-attachment',
    'has a replacement button');
  assert.elementNotFound('.validation-error',
    'does not have validation errors by default');

  this.set('answer.attachments.firstObject.readyIssues', newReadyIssues);
  assert.equal($('.validation-error').length, 2,
    'displays all validation errors when present');

  this.set('answer.attachments.firstObject.readyIssues', newReadyIssues.slice(1));
  assert.equal($('.validation-error').length, 1,
    'displays all validation errors when present');
});
