require 'spec_helper'

describe Notifications::Client do
  it 'has a version number' do
    expect(Notifications::Client::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end

  describe "client" do
    it "should have valid jwt" do
      # todo
    end
  end

  describe "#send_email" do
    it "should send valid notification" do

    end

    it "response includes id" do
      # todo
    end
  end

  describe "#send_sms" do

  end
end
