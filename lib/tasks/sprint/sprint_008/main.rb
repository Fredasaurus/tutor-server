module Sprint008
  class Main

    lev_routine

    protected

    def exec

      # Create users

      teacher             = FactoryGirl.create :user, username: 'teacher'
      student             = FactoryGirl.create :user, username: 'student'
      teacher_and_student = FactoryGirl.create(:user, username: 'teacher_and_student')

      # Make 2 courses

      course1 = Domain::CreateCourse[name: 'Physics']
      course2 = Domain::CreateCourse[name: 'Fundamentals of Risk']

      # Import the sample content book and add it to a course

      book = Domain::FetchAndImportBook[id: '7db9aa72-f815-4c3b-9cb6-d50cf5318b58']
      Domain::AddBookToCourse[book: book, course: course1]

      # Add the teachers to their courses

      Domain::AddUserAsCourseTeacher[course: course1, user: teacher]
      Domain::AddUserAsCourseTeacher[course: course2, user: teacher_and_student]

      # Add the students to the courses

      Domain::AddUserAsCourseStudent[course: course1, user: student]
      student_role = Entity::Role.last
      Domain::AddUserAsCourseStudent[course: course2, user: teacher_and_student]

      # Set up three reading tasks (will include try another)

      a = FactoryGirl.create :assistant, code_class_name: "IReadingAssistant"
      tp = FactoryGirl.create :task_plan, assistant: a,
                                          owner: course1,
                                          settings: { page_ids: [1, 2] }
      tp.tasking_plans << FactoryGirl.create(:tasking_plan, target: student,
                                                            task_plan: tp)
      DistributeTasks.call(tp)

      tp = FactoryGirl.create :task_plan, assistant: a,
                                          owner: course1,
                                          settings: { page_ids: [3] }
      tp.tasking_plans << FactoryGirl.create(:tasking_plan, target: student,
                                                            task_plan: tp)
      DistributeTasks.call(tp)

      tp = FactoryGirl.create :task_plan, assistant: a,
                                          owner: course1,
                                          settings: { page_ids: [4] }
      tp.tasking_plans << FactoryGirl.create(:tasking_plan, target: student,
                                                            task_plan: tp)
      DistributeTasks.call(tp)

      # Set up a practice widget

      Domain::ResetPracticeWidget.call(role: student_role, page_ids: [])

      # Outputs

      outputs[:teacher] = teacher
      outputs[:student] = student
      outputs[:teacher_and_student] = teacher_and_student
      outputs[:course1] = course1
      outputs[:course2] = course2

    end

  end
end