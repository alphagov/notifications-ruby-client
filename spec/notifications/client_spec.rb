require "spec_helper"

describe Notifications::Client do
  it "has a version number" do
    expect(Notifications::Client::VERSION).not_to be nil
  end

  let(:client) { build :notifications_client }

  describe "#send_sms" do

  end
end
