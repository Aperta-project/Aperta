`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

DocumentDownloadService = Ember.Namespace.create
  initiate: (paperId, downloadFormat) ->
    @paperId = paperId
    @downloadFormat = downloadFormat
    Ember.$.ajax
      url: "/papers/#{@paperId}/export",
      data: {format: @downloadFormat}
      success: (data) =>
        jobId = data['job']['id']
        @checkJobState(jobId)
      error: (data) ->
        throw new Error("Could not download #{@downloadFormat}")

  checkJobState: (jobId) ->
    status = ""
    @timeout = 2000
    Ember.$.ajax
      url: "/papers/#{@paperId}/status/#{jobId}",
      success: (data) =>
        job = data['job']
        if job.state == "completed"
          file = job.outputs.findBy("file_type", @downloadFormat)
          Utils.windowLocation file.url
        else if job.state == "errored"
          alert("The download failed")
        else
          setTimeout (=>
            @checkJobState jobId
          ), @timeout

`export default DocumentDownloadService`
