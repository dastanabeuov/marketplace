// Регистрация контроллеров админки: общие (controllers/*) + админские (admin_controllers/*).

import { application } from "controllers/application"

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
eagerLoadControllersFrom("admin_controllers", application)
