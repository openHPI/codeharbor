/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// JS
import * as bootstrap from 'bootstrap/dist/js/bootstrap.bundle';
window.bootstrap = bootstrap; // Publish bootstrap in global namespace

// I18n locales
import { I18n } from "i18n-js";
import locales from "../../tmp/locales.json";

// Fetch user locale from html#lang.
// This value is being set on `app/views/layouts/application.html.slim` and
// is inferred from `ACCEPT-LANGUAGE` header.
const userLocale = document.documentElement.lang;

export const i18n = new I18n();
i18n.store(locales);
i18n.defaultLocale = "en";
i18n.enableFallback = true;
i18n.locale = userLocale;
window.I18n = i18n;
