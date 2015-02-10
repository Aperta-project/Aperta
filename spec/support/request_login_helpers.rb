module LoginHelpers

  def login(user)
    post(user_session_path, {
      user: {
        login: user.username,
        password: user.password
      }
    })
  end

end
