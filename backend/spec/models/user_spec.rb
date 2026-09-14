require "rails_helper"

RSpec.describe User do
  it "downcases and strips the email" do
    expect(create(:user, email: "  Diver@Appnea.TEST ").email).to eq("diver@appnea.test")
  end

  it "rejects a duplicate email regardless of case" do
    create(:user, email: "diver@appnea.test")
    expect(build(:user, email: "DIVER@appnea.test")).not_to be_valid
  end

  it "rejects a malformed email" do
    expect(build(:user, email: "not-an-email")).not_to be_valid
  end

  it "rejects a password shorter than 8 characters" do
    expect(build(:user, password: "short")).not_to be_valid
  end

  it "authenticates with the right password" do
    user = create(:user, password: "password123")
    expect(user.authenticate("password123")).to eq(user)
    expect(user.authenticate("wrong")).to be false
  end
end
