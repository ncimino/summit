module ApplicationHelper
  def title(page_title)
    view_flow.content.delete(:title)
    content_for :title do
      page_title
    end
    page_title
  end

  def default_title(page_title)
    title page_title unless content_for?(:title)
  end

  def logo
    image_tag("econ_f_64.gif", {:alt => "eContriver", :class => "round", :style => "width: 64px; height: 64px"})
  end
end
