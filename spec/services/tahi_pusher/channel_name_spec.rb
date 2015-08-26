require "rails_helper"

describe TahiPusher::ChannelName do

  describe ".build" do
    context "public channel" do
      context "without model" do
        it "builds channel name without access" do
          channel_name = TahiPusher::ChannelName.build(target: "system", access: "public")
          expect(channel_name).to eq("system")
        end
      end

      context "with model" do
        let(:paper) { FactoryGirl.create(:paper) }

        it "builds channel name without access" do
          channel_name = TahiPusher::ChannelName.build(target: paper, access: "public")
          expect(channel_name).to eq("paper@#{paper.id}")
        end
      end

      context "without target" do
        it "throws error" do
          expect {
            TahiPusher::ChannelName.build(target: nil, access: "public")
          }.to raise_error(TahiPusher::ChannelResourceNotFound)
        end
      end
    end


    context "private channel" do
      context "without model" do
        it "builds channel name with access" do
          channel_name = TahiPusher::ChannelName.build(target: "system", access: "private")
          expect(channel_name).to eq("private-system")
        end
      end

      context "with model" do
        let(:paper) { FactoryGirl.create(:paper) }

        it "builds channel name with access" do
          channel_name = TahiPusher::ChannelName.build(target: paper, access: "private")
          expect(channel_name).to eq("private-paper@#{paper.id}")
        end
      end
    end
  end

  describe ".parse channel name" do
    describe "system" do
      let(:channel_name) { "system" }

      it "has a public access" do
        expect(TahiPusher::ChannelName.parse(channel_name).access).to eq("public")
      end

      it "has a string target" do
        expect(TahiPusher::ChannelName.parse(channel_name).target).to eq("system")
      end

      it "is not active record backed" do
        expect(TahiPusher::ChannelName.parse(channel_name)).to_not be_active_record_backed
      end
    end

    describe "paper@4" do
      let(:paper) { FactoryGirl.create(:paper) }
      let(:channel_name) { "paper@#{paper.id}" }

      it "has a public access" do
        expect(TahiPusher::ChannelName.parse(channel_name).access).to eq("public")
      end

      it "has a model target" do
        expect(TahiPusher::ChannelName.parse(channel_name).target).to eq(paper)
      end

      it "is active record backed" do
        expect(TahiPusher::ChannelName.parse(channel_name)).to be_active_record_backed
      end
    end

    describe "private-paper@4" do
      let(:paper) { FactoryGirl.create(:paper) }
      let(:channel_name) { "private-paper@#{paper.id}" }

      it "has a private access" do
        expect(TahiPusher::ChannelName.parse(channel_name).access).to eq("private")
      end

      it "has a model target" do
        expect(TahiPusher::ChannelName.parse(channel_name).target).to eq(paper)
      end

      it "is active record backed" do
        expect(TahiPusher::ChannelName.parse(channel_name)).to be_active_record_backed
      end
    end

    describe "private-paper@4 (when paper does not exist)" do
      let(:channel_name) { "private-paper@4" }

      it "raises an error" do
        expect { TahiPusher::ChannelName.parse(channel_name).target }.to raise_error(TahiPusher::ChannelResourceNotFound)
      end
    end

    describe "private-latex" do
      let(:channel_name) { "private-latex" }

      it "has a private access" do
        expect(TahiPusher::ChannelName.parse(channel_name).access).to eq("private")
      end

      it "has a string target" do
        expect(TahiPusher::ChannelName.parse(channel_name).target).to eq("latex")
      end

      it "is not active record backed" do
        expect(TahiPusher::ChannelName.parse(channel_name)).to_not be_active_record_backed
      end
    end
  end
end
