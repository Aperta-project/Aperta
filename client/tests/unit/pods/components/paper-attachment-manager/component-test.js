import { moduleFor, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleFor(
  'component:paper-attachment-manager',
  'Unit | Component | paper attachment manager',
  {
    // Specify the other units that are required for this test
    // needs: ['component:foo', 'helper:bar'],
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      this.registry.register(
        'pusher:main',
        Ember.Object.extend({ socketId: 'foo' })
      );
    }
  }
);

test(`creating a new paper file`, function(assert) {
  let done = assert.async();
  let cardEvent = this.container.lookup('service:card-event');
  cardEvent.on('onPaperFileUploaded', name => {
    assert.equal(
      name,
      'sourcefile',
      'it triggers the event with the attachment type'
    );
    done();
  });

  let task = make('task', { paper: make('paper') });
  let component = this.subject({ attachmentType: 'sourcefile', task });

  $.mockjax({
    url: `/api/tasks/${task.id}/upload_manuscript`,
    type: 'POST',
    status: 201,
    responseText: { sourcefileAttachment: {id: 1} }
  });
  Ember.run(() => {
    component.send('createFile', 'fakeUrl', 'file');
  });
});
