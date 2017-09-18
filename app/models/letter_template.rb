# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :body, presence: true
  validates :subject, presence: true
  validate :template_scenario?
  validate :body_ok?
  validate :subject_ok?

  def render(context)
    tap do |my|
      # This is just an in-memory edit (render) of the letter template
      # fields that then get passed to the serializer. DO NOT save the
      # rendered versions.
      my.subject = render_attr(subject, context, sanitize: true)
      my.to = render_attr(to, context, sanitize: true)
      my.body = render_attr(body, context)
    end
  end

  def merge_fields
    scenario.constantize.merge_fields
  end

  def blank_render_fields?(liquid_template, context)
    liquid_variables = get_liquid_variables(liquid_template.root.nodelist).flatten
    liquid_variables.any? { |node| blank_liquid_variable?(node.name.name, node.name.lookups, context) }
  end

  private

  def blank_liquid_variable?(name, lookups, context)
    if context.keys.all? { |key| key.is_a? Symbol }
      context[name.to_sym].blank? || (!lookups.empty? && lookups.any? { |lookup| context[name.to_sym][lookup.to_sym].blank? })
    else
      context[name].blank? || (!lookups.empty? && lookups.any? { |lookup| context[name][lookup].blank? })
    end
  end

  def get_liquid_variables(liquid_nodelist)
    vars = []
    liquid_nodelist.each do |node|
      vars << node if node.is_a? Liquid::Variable
      vars << get_liquid_variables(node.nodelist) if node.is_a?(Liquid::Block) || node.is_a?(Liquid::BlockBody)
    end
    vars
  end

  def render_attr(template, context, sanitize: false)
    raw = Liquid::Template.parse(template)
    raise BlankRenderFieldsError if blank_render_fields?(raw, context)
    raw_render = raw.render(context)
    if sanitize
      ActionView::Base.full_sanitizer.sanitize(raw_render)
    else
      raw_render
    end
  end

  def template_scenario?
    scenario_class = begin
      scenario.constantize
    rescue NameError
      false
    end
    return if scenario_class && scenario_class < TemplateScenario

    errors.add(:scenario, 'must name a subclass of TemplateScenario')
  end

  def body_ok?
    Liquid::Template.parse(body)
  rescue Liquid::SyntaxError => e
    errors.add(:body, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end

  def subject_ok?
    Liquid::Template.parse(subject)
  rescue Liquid::SyntaxError => e
    errors.add(:subject, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end
end

class BlankRenderFieldsError; end
