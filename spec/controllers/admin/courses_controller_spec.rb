require 'rails_helper'

RSpec.describe Admin::CoursesController do
  let(:admin) { FactoryGirl.create(:user_profile, :administrator) }

  before { controller.sign_in(admin) }

  describe 'GET #index' do
    it 'assigns all CollectCourseInfo output to @courses' do
      CreateCourse[name: 'Hello World']
      get :index

      expect(assigns[:courses].count).to eq(1)
      expect(assigns[:courses].first.name).to eq('Hello World')
    end
  end

  describe 'POST #create' do
    before do
      post :create, course: { name: 'Hello World' }
    end

    it 'creates a blank course profile' do
      expect(CourseProfile::Models::Profile.count).to eq(1)
    end

    it 'sets a flash notice' do
      expect(flash[:notice]).to eq('The course has been created.')
    end

    it 'redirects to /admin/courses' do
      expect(response).to redirect_to(admin_courses_path)
    end
  end

  describe 'POST #students' do
    let!(:course) { CreateCourse[name: 'Physics'] }
    let!(:period) { CreatePeriod[course: course, name: '1st'] }
    let!(:file) { fixture_file_upload('files/test_courses_post_students.csv', 'text/csv') }
    let!(:file2) { fixture_file_upload('files/test_courses_post_students2.csv', 'text/csv') }

    it 'adds students to a course period' do
      expect {
        post :students, id: course.id, course: { period: period.id }, student_roster: file
      }.to change { OpenStax::Accounts::Account.count }.by(3)
      expect(flash[:notice]).to eq('Student roster has been uploaded.')

      student_roster = GetStudentRoster[course: course]
      expect(student_roster.length).to eq(3)
      expect(student_roster[0].full_name).to eq('Carol Burgess')
      expect(student_roster[1].full_name).to eq('Melissa Haynes')
      expect(student_roster[2].full_name).to eq('Alexander Himmel')
    end

    it 'does not add any students if any username has been taken' do
      FactoryGirl.create :user_profile, username: 'alexh'
      expect {
        post :students, id: course.id, course: { period: period.id }, student_roster: file
      }.to change { OpenStax::Accounts::Account.count }.by(0)
      expect(flash[:error]).to eq([
        'Error uploading student roster',
        'On line 4, username alexh has already been taken.'
      ])
    end

    it 'does not add any students if username or email is missing' do
      expect {
        post :students, id: course.id, course: { period: period.id }, student_roster: file2
      }.to change { OpenStax::Accounts::Account.count }.by(0)
      expect(flash[:error]).to eq([
        'Error uploading student roster',
        'On line 2, email is missing.',
        'On line 3, username is missing.',
        'On line 4, username is missing.',
        'On line 4, email is missing.'
      ])
    end
  end

  describe 'GET #edit' do
    let!(:course) { FactoryGirl.create(:course_profile_profile, name: 'Physics I').course }
    let!(:book_1) { FactoryGirl.create(:content_book_part, title: 'Physics').book }
    let!(:uuid_1) { book_1.root_book_part.uuid }
    let!(:version_1) { book_1.root_book_part.version }
    let!(:book_2) { FactoryGirl.create(:content_book_part, title: 'Biology').book }
    let!(:uuid_2) { book_2.root_book_part.uuid }
    let!(:version_2) { book_2.root_book_part.version }
    let!(:course_book) {
      AddBookToCourse.call(course: course, book: book_1)
      CourseContent::Models::CourseBook.where { entity_course_id == my { course.id } }
                                       .where { entity_book_id == my { book_1.id } }
                                       .first
    }

    it 'selects the correct book' do
      get :edit, id: course.id
      expect(assigns[:course_book]).to eq book_1
      expect(assigns[:books].sort { |a, b| a.id <=> b.id }).to eq([
        {
          'id' => book_1.id,
          'title' => 'Physics',
          'url' => book_1.root_book_part.url,
          'uuid' => uuid_1,
          'version' => version_1,
          'title_with_id' => "Physics (#{uuid_1}@#{version_1})"
        },
        {
          'id' => book_2.id,
          'title' => 'Biology',
          'url' => book_2.root_book_part.url,
          'uuid' => uuid_2,
          'version' => version_2,
          'title_with_id' => "Biology (#{uuid_2}@#{version_2})"
        }
      ])
    end
  end

  describe 'POST #set_book' do
    let!(:course) { FactoryGirl.create(:course_profile_profile, name: 'Physics I').course }
    let!(:book_1) { FactoryGirl.create(:content_book_part, title: 'Physics').book }
    let!(:book_2) { FactoryGirl.create(:content_book_part, title: 'Biology').book }
    let!(:course_book) {
      AddBookToCourse.call(course: course, book: book_1)
      course.reload.course_books.first
    }

    context 'when the book is already being used' do
      it 'does not recreate the association' do
        post :set_book, id: course.id, book_id: book_1.id
        cb = course.reload.course_books.first
        expect(cb.id).to eq course_book.id
        expect(flash[:notice]).to eq 'Course book "Physics" is already selected for "Physics I"'
      end
    end

    context 'when a new book is selected' do
      it 'removes the existing association and creates a new one' do
        post :set_book, id: course.id, book_id: book_2.id
        cb = course.reload.books
        expect(cb).to eq [book_2]
        expect(flash[:notice]).to eq 'Course book "Biology" selected for "Physics I"'
      end
    end
  end

  context 'disallowing baddies' do
    it 'disallows unauthenticated visitors' do
      allow(controller).to receive(:current_account) { nil }
      allow(controller).to receive(:current_user) { nil }

      get :index
      expect(response).not_to be_success

      get :new
      expect(response).not_to be_success

      post :create
      expect(response).not_to be_success

      put :update, id: 1
      expect(response).not_to be_success
    end

    it 'disallows non-admin authenticated visitors' do
      non_admin = FactoryGirl.create(:user_profile)
      controller.sign_in(non_admin)

      expect { get :index }.to raise_error(SecurityTransgression)
      expect { get :new }.to raise_error(SecurityTransgression)
      expect { post :create }.to raise_error(SecurityTransgression)
      expect { put :update, id: 1 }.to raise_error(SecurityTransgression)
    end
  end
end
