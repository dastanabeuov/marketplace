class AttachedFormatValidator < ActiveModel::EachValidator
  MAX_SIZE = 300.kilobytes
  ALLOWED_TYPES = %w[image/png image/jpg image/jpeg image/webp]

  def validate_each(record, attribute, _value)
    attachments = Array.wrap(record.send(attribute))

    attachments.each do |attachment|
      next unless attachment.attached?

      unless ALLOWED_TYPES.include?(attachment.content_type)
        record.errors.add(attribute, I18n.t("errors.messages.invalid_image_type"))
      end

      if attachment.byte_size > MAX_SIZE
        record.errors.add(attribute, I18n.t("errors.messages.image_too_large"))
      end
    end
  end
end
