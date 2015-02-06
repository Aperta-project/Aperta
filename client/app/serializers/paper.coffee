`import ApplicationSerializer from 'tahi/serializers/application'`
`import SerializesHasMany from 'tahi/mixins/serializers/serializes-has-many'`

PaperSerializer = ApplicationSerializer.extend(SerializesHasMany)

`export default PaperSerializer`
