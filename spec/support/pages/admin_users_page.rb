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
      !!@element.all('td')[2].find('input[type="checkbox"]').checked?
    end
  end

  def users
    all('.user').map { |u| UserFragment.new u }
  end
end
