# Marketplace

**Marketplace** — это веб-приложение на Ruby on Rails 8, использующее Postgres, Hotwire, Importmap и другие современные инструменты Rails 8.

## ⚙️ Стек технологий

- **Ruby** 3.4.3
- **Rails** 8.0.2
- **PostgreSQL** в качестве базы данных
- **Importmap** для управления JavaScript-зависимостями без Node.js
- **Hotwire (Turbo + Stimulus)** для реактивного фронтенда
- **Propshaft** как современный asset pipeline
- **Solid Cache, Solid Queue, Solid Cable** — фоновые задачи, кэш и WebSockets
- **Puma** как веб-сервер
- **JBuilder** для построения JSON API
- **Kamal** для Docker-деплоймента
- **Thruster** для ускорения Puma с HTTP кешем и сжатием

## 🚀 Установка

1.  Клонируйте репозиторий:
    ```bash
    git clone https://github.com/dastanabeuov/marketplace.git
    cd marketplace
    ```
2.  Установите зависимости:
    ```bash
    bundle install
    ```
3.  Настройте базу данных. Убедитесь, что у вас установлен и запущен PostgreSQL. Затем выполните:
    ```bash
    cp config/database.yml.pg config/database.yml
    # При необходимости отредактируйте config/database.yml
    rails db:create
    rails db:migrate
    rails db:seed
    ```
4.  Запустите веб-сервер:
    ```bash
    ./bin/dev
    ```
    Приложение будет доступно по адресу http://localhost:3000.

## ✅ Запуск тестов

Для запуска тестов (RSpec) выполните команду:

```bash
bundle exec rspec
```

Для запуска статических анализаторов:

```bash
# RuboCop для проверки стиля кода
bundle exec rubocop

# Brakeman для анализа безопасности
bundle exec brakeman
```

## 🚢 Развертывание

Проект настроен для развертывания с помощью [Kamal](https://kamal-deploy.org/). Для деплоя необходимо настроить `config/deploy.yml` и выполнить:

```bash
kamal deploy
```

## 🏛️ Архитектура

Приложение следует стандартной архитектуре Ruby on Rails:

-   **app/controllers:** Обрабатывают входящие HTTP-запросы.
-   **app/models:** Отвечают за бизнес-логику и взаимодействие с базой данных (Active Record).
-   **app/views:** Генерируют HTML-ответы (используя ERB и Hotwire/Turbo).
-   **app/jobs:** Выполняют фоновые задачи с помощью Solid Queue.
-   **config/routes.rb:** Определяет маршрутизацию URL.
-   **db/schema.rb:** Описывает текущую схему базы данных.