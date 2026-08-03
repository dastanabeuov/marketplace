module ImageSizeHelper
  # Явные width/height на <img> — браузер резервирует место под картинку ещё до её
  # загрузки, поэтому вёрстка не «прыгает» (метрика CLS в Lighthouse).
  #
  # У статичных картинок из app/assets/images размеры проставлены прямо в разметке.
  # Здесь — вложения Active Storage: их загружают через админку, размеры заранее
  # не известны и берутся из метаданных блоба.
  #
  # Сами файлы не пережимаем: атрибуты только сообщают браузеру пропорции,
  # фактический размер на экране по-прежнему задаёт CSS.

  # Оригинал вложения, без обработки
  def sized_attachment_image_tag(attachment, **options)
    image_tag(url_for(attachment), **blob_dimensions(attachment.blob).merge(options))
  end

  # Уменьшенный вариант
  def sized_variant_image_tag(attachment, resize_to_limit:, **options)
    variant    = attachment.variant(resize_to_limit: resize_to_limit).processed
    dimensions = limited_dimensions(blob_dimensions(attachment.blob), resize_to_limit)

    image_tag(variant, **dimensions.merge(options))
  end

  private

  # Размеры Active Storage считает при загрузке файла. У вложений, загруженных до
  # появления анализаторов, метаданных может не быть — тогда ставим анализ в очередь
  # и один раз отдаём разметку без размеров, со следующего рендера они появятся.
  # Считать на лету нельзя: на странице со списком это скачало бы разом все файлы.
  def blob_dimensions(blob)
    return {} if blob.blank?

    unless blob.analyzed?
      blob.analyze_later
      return {}
    end

    width  = blob.metadata[:width]
    height = blob.metadata[:height]
    return {} if width.blank? || height.blank?

    { width: width, height: height }
  rescue StandardError => e
    Rails.logger.warn("Не удалось определить размеры вложения #{blob.filename}: #{e.message}")
    {}
  end

  # resize_to_limit только уменьшает и сохраняет пропорции, поэтому итоговый размер
  # варианта считается той же арифметикой — сам файл варианта читать не нужно.
  def limited_dimensions(dimensions, (max_width, max_height))
    return {} if dimensions.blank?

    width, height = dimensions.values_at(:width, :height)
    scale = [ max_width.to_f / width, max_height.to_f / height, 1.0 ].min

    { width: (width * scale).round, height: (height * scale).round }
  end
end
