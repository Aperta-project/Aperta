import DS from 'ember-data';

export default DS.ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    phaseTemplates: { serialize: 'records', deserialize: 'ids'}
  }
});
