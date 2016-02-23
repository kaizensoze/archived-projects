module NavigationHelper
  def unread_message_highlight(query)
    if query.any_unread?
      'nklyn-yellow'
    else
      ''
    end
  end
end