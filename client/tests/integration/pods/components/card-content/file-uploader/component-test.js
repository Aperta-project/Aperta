import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/file-uploader',
  'Integration | Component | card content | file uploader',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.setProperties({
        actionStub: function() {},
        content: Ember.Object.create({
          ident: 'test',
          allowFileCaptions: true,
          allowMultipleUploads: true,
          label: 'Upload',
          text: 'Please upload a file'
        }),
        answer: Ember.Object.create({ value: null, attachments: [] })
      });
    }
  }
);

let template = hbs`{{card-content/file-uploader
                      answer=answer
                      content=content
                      disabled=disabled
                      preview=preview
                    }}`;

test(`shows an uploader with text and a button`, function(assert) {
  this.render(template);
  assert.textPresent(
    '.description',
    'Please upload a file',
    `the content's text is the uploader's description`
  );

  assert.textPresent(
    '.fileinput-button',
    'Upload',
    'The label displayed as the file upload button text'
  );

  this.set('disabled', true);
  assert.elementNotFound(
    'fileinput-button',
    'disabling will hide the button unless alwaysShowAddButton is set to true'
  );
  assert.textNotPresent(
    '.description',
    'Please upload a file',
    `the description is hidden when the uploader is disabled (like when the task is completed)`
  );

  this.setProperties({ disabled: false, preview: true });
  assert.elementFound(
    '.button--disabled',
    'preview will also disable the button'
  );
  assert.textPresent(
    '.description',
    'Please upload a file',
    `the description shows when the uploader is in preview mode (like on the card editor)`
  );

  this.setProperties({ disabled: false, preview: false });
  this.set('content.allowMultipleUploads', false);
  this.set('answer.attachments', [{ filename: 'foo.txt', src: 'foo' }]);
  assert.elementNotFound(
    '.fileinput-button',
    `Doesn't show the button when multiple=false and there's an existing upload`
  );
});
