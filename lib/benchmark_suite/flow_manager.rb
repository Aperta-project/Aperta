require 'benchmark'

module BenchmarkSuite
  class FlowManager
    def initialize(num_papers:)
      ActiveRecord::Base.subclasses.each(&:delete_all)
      time = Benchmark.realtime {
        create_phase_template_with_remaining_tasks
        create_papers(num_papers)
        complete_metadata_phase_tasks
        assign_roles
        setup_flows users: [site_admin, big_admin, small_admin]
      }
      p time
    end

    def assign_roles
      big_role = big_journal.old_roles.create! name: "Big Admin",
        can_administer_journal: true,
        can_view_flow_manager: true
      big_admin.user_roles.create! old_role_id: big_role.id

      small_role = small_journal.old_roles.create! name: "Small Admin",
        can_administer_journal: true,
        can_view_flow_manager: true
      small_admin.user_roles.create! old_role_id: small_role.id
    end

    def setup_flows(users:)
      Flow.defaults.destroy_all
      users.each do |user|
        flows = []
        flows << Flow.create(title: 'Up for grabs',
                             query: { state: :incomplete })
        flows << Flow.create(title: 'My tasks',
                             query: { assigned: true })
        flows << Flow.create(title: 'Done',
                             query: { state: :completed })

        flows.each do |flow|
          UserFlow.create! user_id: user.id, flow_id: flow.id
        end
      end
    end

    def complete_metadata_phase_tasks
      phase_ids = Phase.where(name: "Metadata Tasks").select(:id).map(&:id)
      sleep 1
      Task.where(phase_id: phase_ids).update_all(completed: true)
    end

    def site_admin
      @site_admin ||= FactoryGirl.create(:user, site_admin: true)
    end

    def big_admin
      @big_admin ||= FactoryGirl.create(:user)
    end

    def small_admin
      @small_admin ||= FactoryGirl.create(:user)
    end

    def create_papers(num_papers)
      big_num = (num_papers * 0.8).to_i
      small_num = (num_papers * 0.2).to_i

      really_create_papers(small_num, small_journal)
      really_create_papers(big_num, big_journal)
    end

    def create_phase_template_with_remaining_tasks
      journals.each do |journal|
        task_types = journal.journal_task_types
        mmt = journal.manuscript_manager_templates.first
        phase = mmt.phase_templates.create! name: "Metadata Tasks"
        JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(
          phase,
          task_types,
          StandardTasks::CompetingInterestsTask,
          StandardTasks::DataAvailabilityTask,
          StandardTasks::EthicsTask,
          StandardTasks::PublishingRelatedQuestionsTask,
          StandardTasks::ReportingGuidelinesTask,
          StandardTasks::ReviewerReportTask,
          StandardTasks::TaxonTask,
          StandardTasks::FinancialDisclosureTask
        )
      end
    end

    def big_journal
      @big_journal ||= JournalFactory.create(name: '80% paper journal')
    end

    def small_journal
      @small_journal ||= JournalFactory.create(name: '20% paper journal')
    end

    def journals
      [big_journal, small_journal]
    end

    private

    def really_create_papers(num, journal)
      time = Benchmark.realtime do
        num.times do |number|
          paper = FactoryGirl.create :paper, journal: journal, creator: site_admin
          PaperFactory.new(paper, paper.creator).add_phases_and_tasks
          puts "created #{number} paper"
        end
      end
      puts "#{num} Papers: #{time}"
    end

  end
end
