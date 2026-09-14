require "rails_helper"

RSpec.describe "Api::Auth" do
  def json = JSON.parse(response.body)

  describe "POST /api/auth/signup" do
    let(:params) { { user: { name: "Rina", email: "rina@appnea.test", password: "password123" } } }

    it "creates a student and returns a token" do
      expect { post "/api/auth/signup", params: params }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["user"]).to include("email" => "rina@appnea.test", "role" => "student")
      expect(json["token"]).to be_present
    end

    it "never lets the caller choose its own role" do
      post "/api/auth/signup", params: { user: params[:user].merge(role: "admin") }

      expect(response).to have_http_status(:created)
      expect(User.last.role).to eq("student")
    end

    it "rejects a duplicate email" do
      create(:user, email: "rina@appnea.test")
      post "/api/auth/signup", params: params

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["details"]).to have_key("email")
    end

    it "rejects a short password" do
      post "/api/auth/signup", params: { user: params[:user].merge(password: "short") }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "never returns the password digest" do
      post "/api/auth/signup", params: params
      expect(json["user"]).not_to have_key("password_digest")
    end
  end

  describe "POST /api/auth/login" do
    let!(:user) { create(:user, email: "diver@appnea.test", password: "password123") }

    it "returns a token for the right password" do
      post "/api/auth/login", params: { session: { email: "diver@appnea.test", password: "password123" } }

      expect(response).to have_http_status(:ok)
      expect(json["token"]).to be_present
      expect(Auth::Token.decode(json["token"])["sub"]).to eq(user.id)
    end

    it "accepts the email in any case" do
      post "/api/auth/login", params: { session: { email: "DIVER@Appnea.test", password: "password123" } }
      expect(response).to have_http_status(:ok)
    end

    it "rejects a wrong password" do
      post "/api/auth/login", params: { session: { email: "diver@appnea.test", password: "nope" } }
      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("error" => "invalid_credentials")
    end

    it "answers an unknown email exactly as it answers a wrong password" do
      post "/api/auth/login", params: { session: { email: "ghost@appnea.test", password: "password123" } }
      unknown = [ response.status, response.body ]

      post "/api/auth/login", params: { session: { email: "diver@appnea.test", password: "wrong" } }
      wrong = [ response.status, response.body ]

      # Identical responses, so the endpoint cannot be used to enumerate accounts.
      expect(unknown).to eq(wrong)
    end
  end

  describe "GET /api/auth/me" do
    let(:user) { create(:user) }

    it "returns the current user for a valid token" do
      get "/api/auth/me", headers: { "Authorization" => "Bearer #{Auth::Token.encode(user)}" }

      expect(response).to have_http_status(:ok)
      expect(json["user"]["id"]).to eq(user.id)
    end

    it "401s without a token" do
      get "/api/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "401s on a tampered token" do
      get "/api/auth/me", headers: { "Authorization" => "Bearer #{Auth::Token.encode(user)}tampered" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "401s on an expired token" do
      token = travel_to(10.days.ago) { Auth::Token.encode(user) }
      get "/api/auth/me", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "401s on a token signed with the wrong key" do
      forged = JWT.encode({ sub: user.id, exp: 1.day.from_now.to_i }, "not-the-real-secret", "HS256")
      get "/api/auth/me", headers: { "Authorization" => "Bearer #{forged}" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
