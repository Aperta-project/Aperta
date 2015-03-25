`import TaskController from 'tahi/pods/task/controller'`
`import SavesQuestionsOnClose from 'tahi/mixins/saves-questions-on-close'`

EthicsOverlayController = TaskController.extend SavesQuestionsOnClose,
  actions:
    destroyAttachment: (attachment) ->
      attachment.destroyRecord()

`export default EthicsOverlayController`
