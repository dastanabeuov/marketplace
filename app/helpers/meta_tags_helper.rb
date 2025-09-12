module MetaTagsHelper
  def set_meta_tags(title:, description: nil, image: nil, url: nil, type: "website")
    content_for :title, title
    content_for :og_title, title
    content_for :og_description, description if description.present?
    content_for :og_image, image if image.present?
    content_for :og_url, url || request.original_url
    content_for :og_type, type
  end
end
