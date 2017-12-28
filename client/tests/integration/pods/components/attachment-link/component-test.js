import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';

moduleForComponent('attachment-link', 'Integration | Component | Attachment Link', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);

    this.setProperties({
      draft: 'draft'
    });

    let attachment = FactoryGuy.make('decision-attachment');
    this.set('attachment', attachment);
  }
});

var template = hbs`
      {{attachment-link accept=accept
                        attachment=attachment
                        draft=draft
                        filePath=filePath
                        hasCaption=hasCaption
                        caption=attachment.caption
                        captionChanged=attrs.captionChanged
                        cancelUpload=attrs.cancelUpload
                        deleteFile=attrs.deleteFile
                        noteChanged=attrs.noteChanged
                        uploadFinished=attrs.updateAttachment
                        progress=uploadProgress
                        start=fileAdded
                        multiple=multiple
                        disabled=disabled }}
    `;

test('it renders the file uploader on the attachment-link', function(assert) {
  this.render(template);
  assert.elementFound('input.update-attachment');
});

test('when the user clicks on Replace, the file uploader should be triggered', function(assert) {
  assert.expect(1);

  this.render(template);
  this.$('.update-attachment').on('click', () => { assert.ok(true, 'action invoked'); });
  this.$('.replace-attachment').click();
});