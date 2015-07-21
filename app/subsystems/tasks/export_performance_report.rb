module Tasks
  class ExportPerformanceReport
    lev_routine express_output: :output_filename

    uses_routine GetCourseProfile,
      translations: { outputs: { type: :verbatim } },
      as: :get_course_profile

    uses_routine GetPerformanceReport,
      translations: { outputs: { type: :verbatim } },
      as: :get_performance_report

    protected
    def exec(role:, course:)
      run(:get_course_profile, course: course)
      run(:get_performance_report, course: course, role: role)

      Axlsx::Package.new do |axlsx|
        axlsx.use_shared_strings = true # OS X Numbers interoperability
        axlsx.workbook.styles.fonts.first.name = 'Helvetica Neue'
        create_summary_worksheet(package: axlsx)
        create_data_worksheets(package: axlsx)
        axlsx.serialize(tmp_file_path)
      end

      outputs[:output_filename] = tmp_file_path
      export = Models::PerformanceReportExport.create!(course: course,
                                                       role: role,
                                                       export: File.open(tmp_file_path))
      status.save({ url: export.url })
    end

    private
    def create_summary_worksheet(package:)
      package.workbook.add_worksheet(name: 'Summary') do |sheet|
        sheet.add_row [bold_text("#{outputs.profile.name} Performance Report")]
        sheet.add_row [Date.today]
      end
    end

    def create_data_worksheets(package:)
      outputs.performance_report.each do |report|
        package.workbook.add_worksheet(name: report[:period][:name]) do |sheet|
          sheet.add_row(data_headers(report[:data_headings]))
          sheet.add_row(gather_due_dates(report[:data_headings]))
          sheet.add_row(gather_averages(report[:data_headings]))
          report.students.each do |student|
            sheet.add_row(student_data(student))
          end
        end
      end
    end

    def data_headers(data_headings)
      headings = data_headings.collect(&:title)
      (['Students'] + headings).collect { |header| bold_text(header) }
    end

    def gather_due_dates(data_headings)
      due_dates = data_headings.collect(&:due_at)
      (['Due Date'] + due_dates).collect { |due_date| italic_text(due_date) }
    end

    def gather_averages(data_headings)
      averages = data_headings.collect(&:average)
      (['Average'] + averages).collect { |average| italic_text(average) }
    end

    def student_data(student)
      [student.name] + student.data.collect { |data| score(data) }
    end

    def score(data)
      case data.type
      when 'homework'
        data.correct_exercise_count/data.exercise_count.to_f
      when 'reading'
        data.status.humanize
      else
        raise "Undefined case for data.type #{data.type} " +
              "please define it here, or use one of " +
              "homework, reading"
      end
    end

    def bold_text(content)
      text = Axlsx::RichText.new
      text.add_run(content, b: true)
      text
    end

    def italic_text(content)
      text = Axlsx::RichText.new
      text.add_run(content, i: true)
      text
    end

    def tmp_file_path
      @tmp_file_path ||= ['./tmp/', generate_file_name, '.xlsx'].join('')
    end

    def generate_file_name
      [outputs.profile.name, '_Performance_',
       Time.current.strftime("%Y%m%d-%H%M%S")].join('')
    end
  end
end
