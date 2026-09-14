require "rails_helper"

RSpec.describe "AdminSessions" do
  let!(:admin) { create(:user, :admin, email: "admin@appnea.test", password: "password123") }
  let!(:student) { create(:user, email: "student@appnea.test", password: "password123") }

  def sign_in(email:, password:)
    post "/admin/login", params: { email: email, password: password }
  end

  describe "the guard on /avo" do
    it "redirects an anonymous visitor to the login page, keeping where they were going" do
      get "/avo/resources/courses"

      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to include("/admin/login")
      expect(response.headers["Location"]).to include("next=")
    end

    it "lets a signed-in admin through" do
      sign_in(email: "admin@appnea.test", password: "password123")
      get "/avo/resources/courses"

      expect(response).to have_http_status(:ok)
    end

    it "sends a signed-in admin from /avo into the panel, not back to login" do
      sign_in(email: "admin@appnea.test", password: "password123")
      get "/avo"

      # Avo's home redirects to the first resource once someone is signed in.
      expect(response.headers["Location"]).to include("/avo/resources/")
    end

    it "turns a signed-in student away" do
      sign_in(email: "student@appnea.test", password: "password123")
      get "/avo"

      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to include("/admin/login")
    end
  end

  describe "POST /admin/login" do
    it "signs an admin in" do
      sign_in(email: "admin@appnea.test", password: "password123")

      expect(response).to have_http_status(:found)
      expect(session[:admin_user_id]).to eq(admin.id)
    end

    it "accepts the email in any case" do
      sign_in(email: "ADMIN@Appnea.test", password: "password123")
      expect(session[:admin_user_id]).to eq(admin.id)
    end

    it "refuses a correct password on a non-admin account" do
      sign_in(email: "student@appnea.test", password: "password123")

      expect(response).to have_http_status(:unauthorized)
      expect(session[:admin_user_id]).to be_nil
    end

    it "gives a non-admin the same message as a wrong password" do
      sign_in(email: "student@appnea.test", password: "password123")
      non_admin = [ response.status, flash[:alert] ]

      sign_in(email: "admin@appnea.test", password: "wrong")
      wrong_password = [ response.status, flash[:alert] ]

      # Same status and same wording, so the form cannot be used to work out
      # which accounts are admins. (The rendered HTML differs only by the CSRF
      # token and the email echoed back into the field.)
      expect(non_admin).to eq(wrong_password)
      expect(non_admin.last).to eq("Those details did not match an admin account.")
    end

    it "rejects a request without a CSRF token when forgery protection is on" do
      # Set on the controller itself: the class-level attribute was already
      # inherited at boot, so flipping it on ActionController::Base now would
      # not reach this subclass.
      AdminController.allow_forgery_protection = true

      post "/admin/login", params: { email: "admin@appnea.test", password: "password123" }

      # Rails turns the InvalidAuthenticityToken into a 422 rather than letting
      # it escape, so a forged POST signs nobody in.
      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:admin_user_id]).to be_nil
    ensure
      AdminController.allow_forgery_protection = false
    end

    it "sends the visitor on to where they were headed" do
      post "/admin/login", params: { email: "admin@appnea.test", password: "password123", next: "/avo/resources/bookings" }
      expect(response).to redirect_to("/avo/resources/bookings")
    end

    it "ignores an off-site next parameter" do
      post "/admin/login", params: { email: "admin@appnea.test", password: "password123", next: "//evil.test/phish" }
      expect(response).to redirect_to("/avo")
    end

    it "ignores an absolute off-site next parameter" do
      post "/admin/login", params: { email: "admin@appnea.test", password: "password123", next: "https://evil.test" }
      expect(response).to redirect_to("/avo")
    end
  end

  describe "DELETE /admin/logout" do
    it "clears the session" do
      sign_in(email: "admin@appnea.test", password: "password123")
      delete "/admin/logout"

      expect(session[:admin_user_id]).to be_nil
      get "/avo"
      expect(response).to have_http_status(:found)
    end
  end
end
