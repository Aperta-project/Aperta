class MergeFieldBuilder
  def self.merge_fields(context)
    field_names  = context.public_instance_methods - TemplateContext.public_instance_methods
    field_names -= blacklisted_merge_fields[context]
    field_names -= complex_merge_fields[context].map { |mf| mf[:name] }

    basic_fields   = field_names.map { |field_name| { name: field_name } }
    complex_fields = complex_merge_fields[context].map { |mf| expand_context(mf) }

    basic_fields + complex_fields
  end

  def self.expand_context(merge_field)
    context = merge_field.delete(:context)
    merge_field[:children] = merge_fields(context) if context
    merge_field
  end

  # rubocop:disable Metrics/MethodLength
  def self.complex_merge_fields
    @complex_merge_fields ||= Hash.new { [] }.tap do |hash|
      hash[ReviewerReportScenario] = [
        { name: :review,     context: ReviewerReportContext },
        { name: :reviewer,   context: UserContext },
        { name: :journal,    context: JournalContext },
        { name: :manuscript, context: PaperContext }
      ]
      hash[TahiStandardTasks::PaperReviewerScenario] = [
        { name: :invitation, context: InvitationContext },
        { name: :journal,    context: JournalContext },
        { name: :manuscript, context: PaperContext }
      ]
      hash[TahiStandardTasks::PreprintDecisionScenario] = [
        { name: :manuscript, context: PaperContext },
        { name: :journal,    context: JournalContext }
      ]
      hash[TahiStandardTasks::RegisterDecisionScenario] = [
        { name: :manuscript, context: PaperContext },
        { name: :journal,    context: JournalContext },
        { name: :reviews,    context: ReviewerReportContext, many: true }
      ]
      hash[PaperContext] = [
        { name: :editor,                context: UserContext },
        { name: :academic_editors,      context: UserContext,   many: true },
        { name: :handling_editors,      context: UserContext,   many: true },
        { name: :authors,               context: AuthorContext, many: true },
        { name: :corresponding_authors, context: AuthorContext, many: true }
      ]
      hash[ReviewerReportContext] = [
        { name: :reviewer, context: UserContext },
        { name: :answers,  context: AnswerContext, many: true }
      ]
    end
  end

  def self.blacklisted_merge_fields
    @blacklisted_merge_fields ||= Hash.new { [] }.tap do |hash|
      hash[PaperContext] = [:url_for, :url_helpers]
      hash[ReviewerReportContext] = ActionView::Helpers::SanitizeHelper.public_instance_methods
    end
  end
end
