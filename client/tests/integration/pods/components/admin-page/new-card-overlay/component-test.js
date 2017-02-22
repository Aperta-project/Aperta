import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';

moduleForComponent('admin-page/new-card-overlay', 'Integration | Component | Admin page | new card overlay', {
  integration: true
});

const mockStore = {
  createRecord() {
    return {
      save() {
        const catcher = { catch() {}};

        return {
          then(callback) {
            callback();
            return catcher;
          }
        };
      }
    };
  }
};


test('it creates a record when the save button is pushed', function(assert) {
  this.set('store', mockStore);
  const create = sinon.spy();
  const complete = sinon.spy();
  const close = sinon.spy();
  this.on('create', create);
  this.on('complete', complete);
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    create=(action "create")
    complete=(action "complete")
    close=(action "close")}}`);

  this.$('.admin-new-card-overlay-save').click();

  assert.spyCalled(create, 'Should call create');
  assert.spyCalled(complete, 'Should call complete');
  assert.spyNotCalled(close, 'Should not call close');
});


test('it does not create a record when the cancel button is pushed', function(assert) {
  this.set('store', mockStore);
  const create = sinon.spy();
  const complete = sinon.spy();
  const close = sinon.spy();
  this.on('create', create);
  this.on('complete', complete);
  this.on('close', close);

  this.render(hbs`{{admin-page/new-card-overlay
    store=store
    journal=journal
    create=(action "create")
    complete=(action "complete")
    close=(action "close")}}`);

  this.$('.admin-new-card-overlay-cancel').click();

  assert.spyNotCalled(create, 'Should not call create');
  assert.spyNotCalled(complete, 'Should not call complete');
  assert.spyCalled(close, 'Should call close');
});
