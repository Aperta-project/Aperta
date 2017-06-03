class QuestionAttachmentSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src,
             :ready,
             :ready_issues

    def ready_issues
      return [] unless object.ready_issues
      issues = []
      object.ready_issues.each do |k,v|
        issues << v
      end

      return issues
    end
end
