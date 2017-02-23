import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import { instaPromise } from 'tahi/tests/helpers/promise-helpers';

moduleForComponent('admin-page/new-card-overlay', 'Integration | Component | Admin page | new card overlay', {
  integration: true
});


function mockStore(record) {
  return {
    createRecord() {
      return record;
    }
  };
};

test('it creates a record when the save button is pushed', function(assert) {
  const mockRecord = {
    save() {
      return instaPromise(true, { id: 37 });
    }
  };
  sinon.stub(mockRecord, 'save', mockRecord.save);

  this.set('store', mockStore(mockRecord));
  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    close=(action "close")}}`);

  this.$('.admin-new-card-overlay-save').click();
  assert.spyCalled(mockRecord.save, 'should save a new record');
  assert.spyCalled(close, 'Should call close');
});


test('it does not create a record when the cancel button is pushed', function(assert) {
  const mockRecord = {
    save() {
      return instaPromise(true, { id: 37 });
    }
  };
  sinon.stub(mockRecord, 'save', mockRecord.save);

  this.set('store', mockStore(mockRecord));

  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    close=(action "close")}}`);

  this.$('.admin-new-card-overlay-cancel').click();

  assert.spyNotCalled(mockRecord.save, 'should not create a new record');
  assert.spyCalled(close, 'Should call close');
});
