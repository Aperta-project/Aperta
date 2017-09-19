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
}

test('it creates a record when the save button is pushed', function(assert) {
  const mockRecord = {
    save() {
      return instaPromise(true, { id: 37 });
    }
  };
  sinon.stub(mockRecord, 'save', mockRecord.save);

  this.set('store', mockStore(mockRecord));
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    success=(action "success")
    close=(action "close")}}`);

  this.$('.admin-overlay-save').click();
  assert.spyCalled(mockRecord.save, 'should save a new record');
  assert.spyCalled(success, 'Should call success callback');
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
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    success=(action "success")
    close=(action "close")}}`);

  this.$('.admin-overlay-cancel').click();

  assert.spyNotCalled(mockRecord.save, 'should not create a new record');
  assert.spyNotCalled(success, 'Should not call success callback');
  assert.spyCalled(close, 'Should call close');
});
