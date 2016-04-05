require 'rails_helper'

describe PaperTaskFinders do
  it "returns a list of the institution names" do
    paper = FactoryGirl.create :paper_with_task, task_params: { title: "Billing", type: "PlosBilling::BillingTask", old_role: "author" }
    expect(paper.billing_task.type).to eq("PlosBilling::BillingTask")
  end
end
