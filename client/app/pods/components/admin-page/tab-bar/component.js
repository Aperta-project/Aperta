import Ember from 'ember';
import JournalAdminMixin from 'tahi/mixins/components/journal-administratable';

export default Ember.Component.extend(JournalAdminMixin, {
  classNames: ['admin-tab-bar'],
});
