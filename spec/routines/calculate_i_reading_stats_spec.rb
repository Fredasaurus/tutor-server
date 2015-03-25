require 'rails_helper'

describe CalculateIReadingStats do

  let(:number_of_students){ 8 }

  let(:task_plan) {
    FactoryGirl.create :tasked_task_plan,
                       number_of_students: number_of_students
  }

  let(:stats){
    CalculateIReadingStats.call(plan: task_plan).outputs.stats
  }

  context "With an unworked plan" do

    it "is all zero for an unworked task_plan" do
      expect(stats.course.total_count).to eq(task_plan.tasks.length)
      expect(stats.course.complete_count).to eq(0)
      expect(stats.course.partially_complete_count).to eq(0)

      page = stats.course.current_pages[0]
      expect(page.student_count).to eq(8)
      expect(page.incorrect_count).to eq(0)
      expect(page.correct_count).to eq(0)
    end

  end

  context "after tasks are marked as completed" do

    it "records partial/complete status" do

      first_task = task_plan.tasks.first
      step = first_task.task_steps.where(tasked_type:"TaskedReading").first
      MarkTaskStepCompleted.call(task_step: step)

      stats = CalculateIReadingStats.call(plan: task_plan).outputs.stats
      expect(stats.course.complete_count).to eq(0)
      expect(stats.course.partially_complete_count).to eq(1)

      first_task.task_steps.each{ |ts| MarkTaskStepCompleted.call(task_step: ts) }
      stats = CalculateIReadingStats.call(plan: task_plan.reload).outputs.stats

      expect(stats.course.complete_count).to eq(1)
      expect(stats.course.partially_complete_count).to eq(0)

      last_plan=task_plan.tasks.last
      MarkTaskStepCompleted.call(task_step: last_plan.task_steps.first)
      stats = CalculateIReadingStats.call(plan: task_plan.reload).outputs.stats
      expect(stats.course.complete_count).to eq(1)
      expect(stats.course.partially_complete_count).to eq(1)
    end


  end

  context "after tasks are marked as correct" do

    it "records them" do
      first_task = task_plan.tasks.first
      first_task.task_steps.each{ |ts|
        if ts.tasked_type == "TaskedExercise"
          ts.tasked.answer_id = ts.tasked.correct_answer_id
          ts.tasked.free_response = 'a sentence explaining all the things'
          ts.tasked.save!
        end
        MarkTaskStepCompleted.call(task_step: ts)
      }
      stats = CalculateIReadingStats.call(plan: task_plan.reload).outputs.stats
      page = stats.course.current_pages.first
      expect(page['page']['title']).to eq('Force')
      expect(page['student_count']).to eq(number_of_students)
      expect(page['correct_count']).to eq(1)
      expect(page['incorrect_count']).to eq(0)
    end

  end

end
