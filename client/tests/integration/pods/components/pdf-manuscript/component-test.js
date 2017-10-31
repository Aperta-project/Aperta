import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'pdf-manuscript',
  'Integration | Component | paper attachment manager',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);

      this.registry.register(
        'service:pusher',
        Ember.Object.extend({ socketId: 'foo' })
      );
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

test(`replacing a new file`, function(assert) {
  const paper = make('paper', {
    file: {
      fileHash: 'one',
      fileType: 'pdf'
    }
  });

  this.set('paper', paper);

  this.render(hbs` {{pdf-manuscript paper=paper split-pane-element}}`);

  let mockUrl = `/api/paper_downloads/1`;
  let mockInfo = { url: mockUrl, type: 'GET', status: 302 };
  $.mockjax(mockInfo);

  this.set('paper.file.fileHash', 'two');
  return wait().then(() => {
    assert.mockjaxRequestMade(mockUrl, 'GET');
  });
});
