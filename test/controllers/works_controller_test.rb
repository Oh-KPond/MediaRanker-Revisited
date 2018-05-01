require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      # given
        # fixtures
      # when
      get root_path
      # then
      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # given
      # finds movie in fixtures and deletes it
      movie = Work.find(works(:movie).id)
      movie.delete
      # when
      get root_path
      # then
      must_respond_with :success

    end

    it "succeeds with no media" do
      works = Work.all
      works.destroy_all

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    before do
      login(users(:dan))
    end
    it "succeeds when there are works" do

      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      works = Work.all
      works.destroy_all

      get works_path

      must_respond_with :success
    end
  end

  describe "new" do
    before do
      login(users(:dan))
    end
    it "succeeds" do

      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    before do
      login(users(:dan))
    end
    it "creates a work with valid data for a real category" do
      proc   {
        post works_path, params: { work: {title: "Some new work", category: "movie"} }
      }.must_change 'Work.count', 1

      work = Work.find_by(title: "Some new work")

      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      proc   {
        post works_path, params: { work: {title: "Some new work", category: INVALID_CATEGORIES.first } }
      }.must_change 'Work.count', 0

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
# TODO: Create a test here or delete per Dee
    end

  end

  describe "show" do
    before do
      login(users(:dan))
    end
    it "succeeds for an extant work ID" do
      get work_path works(:movie).id

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path 999

      must_respond_with :missing
    end
  end

  describe "edit" do
    before do
      login(users(:dan))
    end
    it "succeeds for an extant work ID" do
      get edit_work_path works(:album).id

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path 999

      must_respond_with :missing
    end
  end

  describe "update" do
    before do
      login(users(:dan))
    end
    it "succeeds for valid data and an extant work ID" do
      # Given
      work_id = works(:poodr).id
      new_title = "New Title"

      # When
      patch work_path work_id, params: {
        work: {
          title: new_title
        }
      }

      edited = Work.find(work_id)

      # Then
      edited.title.must_equal new_title
      must_respond_with :redirect
      must_redirect_to work_path edited.id
    end

    it "renders bad_request for bogus data" do

      patch work_path works(:movie).id, params: {
        work: {
          category: INVALID_CATEGORIES.first
        }
      }

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      put work_path 999

      must_respond_with :missing
    end
  end

  describe "destroy" do
    before do
      login(users(:dan))
    end
    it "succeeds for an extant work ID" do

      proc {delete work_path(works(:album).id) }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      proc {delete work_path(999) }.must_change 'Work.count', 0

      must_respond_with :missing
    end
  end

  describe "upvote" do
    before do
      login(users(:dan))
    end
    it "redirects to the work page if no user is logged in" do
      work = Work.find(works(:movie).id)

      post upvote_path work

      must_respond_with :redirect
      must_redirect_to work_path
    end

    it "redirects to the work page after the user has logged out" do
      work = Work.find(works(:movie).id)
      login(users(:dan))

      post upvote_path work

      logout(users(:dan))

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      login(users(:dan))

      proc { post upvote_path works(:poodr).id }.must_change "Vote.count", 1

      must_respond_with :redirect
      must_redirect_to work_path works(:poodr).id
    end

    it "redirects to the work page if the user has already voted for that work" do
      login(users(:dan))

      post upvote_path works(:poodr).id
      proc { post upvote_path works(:poodr).id }.must_change "Vote.count", 0

      must_respond_with :redirect
      must_redirect_to work_path works(:poodr).id
    end
  end

  # def perform_login
  #   post login_path, params: {user: "kari"}
  # end
end
