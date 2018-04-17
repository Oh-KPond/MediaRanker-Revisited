require 'test_helper'

describe UsersController do
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
      
      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path users(:kari).id

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get user_path 999

      must_respond_with :missing
    end
  end
end
