module ImageHelper
  # Пресеты под реальные слоты вёрстки.
  #
  # boxes — рамки вариантов от меньшей к большей. Первая — базовая: размер слота при
  #         обычной плотности пикселей, она идёт в src и в атрибуты width/height.
  #         Все рамки попадают в srcset, и браузер сам выбирает файл под ширину
  #         колонки и плотность экрана.
  # crop  — true, когда у слота фиксированная высота (resize_to_fill режет ровно под
  #         неё). false, когда высота плавает: тогда resize_to_limit только вписывает
  #         в рамку, иначе картинку обрезало бы дважды — здесь и потом в CSS.
  # sizes — ширина слота в вёрстке. Без неё браузер считает, что картинка во всю
  #         ширину экрана, и качает файл крупнее нужного.
  IMAGE_PRESETS = {
    # .product-thumb в карточках списка: 100% × 200px (160px до 576px).
    # Сетка row-cols-md-4 в .container с g-4: колонка 306px на xxl, 246px на sm.
    thumb: {
      crop: true,
      boxes: [ [ 300, 200 ], [ 450, 300 ], [ 600, 400 ] ],
      sizes: "(max-width: 575.98px) calc(100vw - 1.5rem), (max-width: 767.98px) 246px, 306px"
    },
    # col-md-6 на страницах show: до 612px с учётом p-md-4, на мобильном во всю ширину
    detail: {
      crop: false,
      boxes: [ [ 400, 400 ], [ 620, 620 ], [ 920, 920 ] ],
      sizes: "(max-width: 767.98px) calc(100vw - 1.5rem), 612px"
    },
    # логотип в футере — фиксированные 150px, второй вариант для экранов 2x
    logo: {
      crop: false,
      boxes: [ [ 150, 120 ], [ 300, 240 ] ],
      sizes: "150px"
    },
    # превью в админке (w-50): один размер, srcset тут не нужен
    admin: {
      crop: false,
      boxes: [ [ 600, 600 ] ]
    }
  }.freeze

  # webp заметно легче jpeg/png при том же качестве, а исходник не трогается —
  # вариант это отдельный файл.
  IMAGE_FORMAT  = :webp
  IMAGE_QUALITY = 82

  # Заглушка для товаров и компаний без картинки. Статичный ассет, а не вложение:
  # id блоба различается между dev и прод и меняется при переналивке базы.
  IMAGE_PLACEHOLDER = "brand_empty.webp".freeze
  # Собственный размер файла заглушки — нужен, чтобы в рамках без обрезки
  # посчитать честные width/height, а не выдать размер рамки за размер картинки
  IMAGE_PLACEHOLDER_SIZE = { width: 241, height: 150 }.freeze

  # Базовый вариант пресета — тот же, что уходит в src у responsive_image_tag
  def responsive_image(attachment, size:)
    preset = IMAGE_PRESETS.fetch(size)
    image_variant(attachment, preset[:boxes].first, crop: preset[:crop])
  end

  # image_tag с srcset/sizes и явными width/height. Размеры нужны, чтобы браузер
  # резервировал место под картинку ещё до загрузки и вёрстка не «прыгала» (CLS).
  def responsive_image_tag(attachment, size:, **options)
    preset = IMAGE_PRESETS.fetch(size)
    # Картинки нет — отдаём заглушку того же размера. Пустое место вместо <img>
    # укоротило бы карточку, и сетка поехала бы.
    return placeholder_image_tag(preset, **options) unless attachment.attached?

    candidates = image_candidates(attachment, preset)
    # src и width/height берём от базовой рамки — это размер слота при обычной
    # плотности пикселей. Взять самую крупную нельзя: там, где ширину не задаёт CSS
    # (логотип с .img-fluid), атрибут width сам растянет картинку.
    base = candidates.first

    tag_options = { width: base[:width], height: base[:height] }
    if candidates.size > 1
      # Собираем srcset строкой сами: image_tag прогоняет ключи хэша через Propshaft,
      # а варианты Active Storage резолвятся маршрутами, а не путями к ассетам.
      tag_options[:srcset] = candidates.map { |c| "#{url_for(c[:variant])} #{c[:width]}w" }.join(", ")
      tag_options[:sizes]  = preset[:sizes]
    end

    image_tag(base[:variant], **tag_options.compact.merge(options))
  end

  private

  # Заглушка должна занять ровно тот же бокс, что заняла бы настоящая картинка.
  # Там, где слот режет по фиксированной высоте, это размер рамки; там, где картинку
  # только вписывают, — рамка по пропорциям самой заглушки.
  def placeholder_image_tag(preset, **options)
    box = preset[:boxes].first
    dimensions =
      if preset[:crop]
        { width: box.first, height: box.last }
      else
        limited_dimensions(IMAGE_PLACEHOLDER_SIZE, box)
      end

    image_tag(IMAGE_PLACEHOLDER, **dimensions.merge(options))
  end

  def image_variant(attachment, box, crop:)
    transformation = crop ? { resize_to_fill: box } : { resize_to_limit: box }

    attachment.variant(**transformation, format: IMAGE_FORMAT, saver: { quality: IMAGE_QUALITY })
  end

  # Для каждой рамки считаем, какого размера получится файл. У resize_to_fill это
  # ровно рамка, у resize_to_limit — зависит от пропорций оригинала, поэтому считаем.
  # Дубли по ширине убираем: у мелкого оригинала несколько рамок дадут один и тот же
  # файл, а два одинаковых кандидата в srcset только путают браузер.
  def image_candidates(attachment, preset)
    natural = blob_dimensions(attachment.blob)

    candidates = preset[:boxes].filter_map do |box|
      dimensions = preset[:crop] ? { width: box.first, height: box.last } : limited_dimensions(natural, box)
      next if dimensions.blank?

      dimensions.merge(variant: image_variant(attachment, box, crop: preset[:crop]))
    end

    # Размеров оригинала нет (вложение ещё не проанализировано) — отдаём один вариант
    # без srcset, разметка останется валидной
    if candidates.empty?
      box = preset[:boxes].last
      return [ { width: nil, height: nil, variant: image_variant(attachment, box, crop: preset[:crop]) } ]
    end

    candidates.uniq { |c| c[:width] }.sort_by { |c| c[:width] }
  end

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
