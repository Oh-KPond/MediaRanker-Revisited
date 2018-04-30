require 'test_helper'

describe UsersController do

  describe "Guest users" do
    describe "index" do
      it "redirects and provides message" do

        get users_path

        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to do that"
      end
    end

    describe "show" do
      it "redirects and provides message" do
        get user_path users(:kari).id

        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to do that"
      end

      it "renders redirect for a bogus work ID" do
        get user_path 999

        must_respond_with :redirect
        flash[:result_text].must_equal "You must be logged in to do that"
      end
    end
  end

  describe "Logged in users" do
    before do
      login(users(:dan))
    end

    describe "index" do
      it "succeeds when there are users" do

        get users_path

        must_respond_with :success
      end

      it "succeeds when there are no users" do
        users = User.all
        votes = Vote.all
        votes.destroy_all
        users.destroy_all

        user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

        login(user)
        get users_path

        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        get user_path users(:dan).id

        must_respond_with :success
      end

      it "renders 404 not_found for an ID that is not the current user" do
        get user_path users(:kari).id

        must_respond_with :missing
      end

      it "renders 404 not_found for a bogus user ID" do
        get user_path 999

        must_respond_with :missing
      end
    end
  end

  describe "github_login" do
    before do
      login(users(:dan))
    end

    it "logs in an existing user and redirects to the root route" do
      # Given
      start_count = User.count
      user = users(:dan)

      # When
      login(user)

      # Then
      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      # Given
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
      # When
      login(user)
      # Then
      must_redirect_to root_path
      User.count.must_equal start_count + 1
    end
  end
end
