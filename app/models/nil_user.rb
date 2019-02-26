# anonymous users

class NilUser
  include UserDelegates

  def user_rating
    UserRating.new
  end

  def present?
    false
  end
end
