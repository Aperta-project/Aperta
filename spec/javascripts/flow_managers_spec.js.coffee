# Convert the flow data structure into a Backbone Collection
# Add that collection to the Flow component's prop (this.props.myTasks and this.props.myPapers)
# myTasks => [PaperProfile, PaperProfile, PaperProfile]
# PaperProfile => [Paper, [Task, Task]]
#
# paperModel.attributes.set(tasks, [Task1, Task2]
describe 'Flow Manager', ->
  describe '#init', ->

