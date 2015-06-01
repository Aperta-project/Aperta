`import TaskController from 'tahi/pods/paper/task/controller'`

CoverLetterController = TaskController.extend()
  # resultsTemplate: (user) ->
  #   user.email

  # selectedTemplate: (user) ->
  #   # Handle raw object or ember model
  #   if typeof(user.email) is "string"
  #     user.email
  #   else
  #     user.get('email')

  # actions:
    # assignAdmin: (select2User) ->
    #   @store.find('user', select2User.id).then (user) =>
    #     @set('model.admin', user)
    #     @send('saveModel')

`export default CoverLetterController`
