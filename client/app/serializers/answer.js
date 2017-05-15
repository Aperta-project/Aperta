import ApplicationSerializer from 'tahi/serializers/application';
import Ember from 'ember';

export default ApplicationSerializer.extend({
  /**
   * We demodulize Ruby classes in Aperta when they're sent to Ember. This happens
   * in the application serializer on the ember side, at least for models with a 'type'
   * attribute on them.  We save the original (namespaced) class name into a 'qualifiedType'
   * attribute that you can find on any of the Task subclasses if you look in the ember data store.
   * We also demodulize any classnames when they're included as part of a polymorphic relationship.
   * ie {owner: {type: 'TahiStandardTasks::CompetingInterestTask', id: 2} becomes
   *    {owner: {type: 'CompetingInterestTask', id: 2}.
   *
   * That's fine for the read-only case; ember uses the type and id information
   * to look up a record in the store.  If we want to save the relationship info back to the api,
   * though, we have to have the fully namespaced class name.
   *
   * We've chosen to do this by looking for an ownerTypeForAnswer method on the Answerable module,
   * which we refer to below.
   */
  serializePolymorphicType: function(snapshot, json, relationship) {
    let key = relationship.key;
    let belongsTo = snapshot.belongsTo(key);
    key = this.keyForAttribute ? this.keyForAttribute(key, 'serialize') : key;

    if (Ember.isNone(belongsTo)) {
      json[key + '_type'] = null;
    } else {
      json[key + '_type'] = belongsTo.attr('ownerTypeForAnswer');
    }
  }
});
