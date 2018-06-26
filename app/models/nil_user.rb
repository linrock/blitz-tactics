# anonymous users

class NilUser
  include UserDelegates

  def present?
    false
  end
end
