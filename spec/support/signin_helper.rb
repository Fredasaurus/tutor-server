module SigninHelper
  def stub_current_user(user)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_account)
      .and_return(user.account)

    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end
end
