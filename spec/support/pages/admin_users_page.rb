class AdminUsersPage < Page
  path :admin_users

  class UserFragment
    def initialize element
      @element = element
    end

    def id
      @element.all('td')[0].text.to_i
    end

    def admin?
      !!@element.all('td')[4].find('input[type="checkbox"]').checked?
    end

    def set_admin
      @element.all('td')[4].find('input[type="checkbox"]').set(true)
    end
  end

  def users
    all('.user').map { |u| UserFragment.new u }
  end

  def dashboard
    visit '/'
    DashboardPage.new
  end
end
