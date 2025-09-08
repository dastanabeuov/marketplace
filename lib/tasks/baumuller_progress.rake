namespace :baumuller do
  desc "Показать текущий прогресс парсинга"
  task show_progress: :environment do
    progress_file = Rails.root.join("storage", "baumuller_progress.json")

    if File.exist?(progress_file)
      progress = JSON.parse(File.read(progress_file))
      puts JSON.pretty_generate(progress)
    else
      puts "Файл прогресса не найден: #{progress_file}"
    end
  end

  desc "Очистить прогресс парсинга"
  task clear_progress: :environment do
    progress_file = Rails.root.join("storage", "baumuller_progress.json")

    if File.exist?(progress_file)
      File.delete(progress_file)
      puts "Прогресс очищен: #{progress_file}"
    else
      puts "Файл прогресса не найден: #{progress_file}"
    end
  end

  desc "Показать логи парсинга"
  task show_logs: :environment do
    log_file = Rails.root.join("storage", "baumuller_parsing.log")

    if File.exist?(log_file)
      puts File.read(log_file)
    else
      puts "Файл логов не найден: #{log_file}"
    end
  end
end
