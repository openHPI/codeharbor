/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.slim

// JS
import 'jquery';
import 'jquery-ujs'
import 'select2';
import * as bootstrap from 'bootstrap/dist/js/bootstrap.bundle';
import * as Sentry from '@sentry/browser';
import * as SentryIntegration from '@sentry/integrations';
window.bootstrap = bootstrap; // Publish bootstrap in global namespace
window.Sentry = Sentry; // Publish sentry in global namespace
window.SentryIntegrations = function() { // Publish sentry integration in global namespace
  return [
    new SentryIntegration.ReportingObserver(),
    new SentryIntegration.ExtraErrorData(),
    new SentryIntegration.HttpClient(),
    new Sentry.BrowserProfilingIntegration(),
    new Sentry.BrowserTracing(),
    new Sentry.Replay(),
  ]
};

// custom jquery-ui library for minimal mouse interaction support
import 'jquery-ui/ui/widget'
import 'jquery-ui/ui/data'
import 'jquery-ui/ui/disable-selection'
import 'jquery-ui/ui/scroll-parent'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/resizable'
import 'jquery-ui/ui/widgets/selectable'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/themes/base/draggable.css'
import 'jquery-ui/themes/base/core.css'
import 'jquery-ui/themes/base/resizable.css'
import 'jquery-ui/themes/base/selectable.css'
import 'jquery-ui/themes/base/sortable.css'


// I18n locales
import { I18n } from "i18n-js";
import locales from "../../tmp/locales.json";

Promise.all(
    Object.keys(locales).map(locale => import(`select2/dist/js/i18n/${locale}`))
).then(() =>
    document.dispatchEvent(new Event("select2:locales:loaded"))
);

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

// Routes
import * as Routes from 'routes.js.erb';
window.Routes = Routes;
