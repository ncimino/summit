ActiveAdmin.register Page do

  form do |f|
    f.inputs "Page" do
      f.input :name
      f.input :title
      f.input :ordinal
      f.input :url, :as => :url
      f.input :location, :as => :select, :collection => [['Top', 'topbar'], ['Userbar', 'userbar'], ['Sidebar', 'sidebar'], ['Bottom', 'bottombar'], ['Disabled', 'off']]
      f.input :content, :as => :text
    end
    f.buttons
  end

end
