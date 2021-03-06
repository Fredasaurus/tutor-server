class Admin::SchoolsDestroy
  lev_handler

  uses_routine CourseDetail::DeleteSchool, as: :delete_school

  protected
  def authorized?
    true # already authenticated in admin controller base
  end

  def handle
    run(:delete_school, id: params[:id])
  end
end
