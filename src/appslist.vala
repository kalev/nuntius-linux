/*
 * Copyright (C) 2015 - Holy Lobster
 *
 * Nuntius is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Nuntius is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Nuntius. If not, see <http://www.gnu.org/licenses/>.
 */

namespace Nuntius {

public class AppsList : Gtk.ListBox {
    [GtkTemplate (ui = "/org/holylobster/nuntius/ui/approw.ui")]
    public class AppRow : Gtk.ListBoxRow {
        [GtkChild]
        private Gtk.Image image;
        [GtkChild]
        private Gtk.Label label;
        [GtkChild]
        private Gtk.Frame notifications_unread_frame;
        [GtkChild]
        private Gtk.Label notifications_unread_label;

        private NotificationApp _notification_app;

        public NotificationApp notification_app {
            get { return _notification_app; }
            set construct { _notification_app = value; }
        }

        public AppRow(NotificationApp notification_app) {
            Object(notification_app: notification_app);

            image.set_from_gicon(notification_app.icon, Gtk.IconSize.BUTTON);
            notifications_unread_label.set_label(notification_app.unread_notifications.to_string());
            if (notification_app.unread_notifications > 0) {
                notifications_unread_frame.show();
                label.set_markup("<b>" + notification_app.app_name + "</b>");
            } else {
                label.set_label(notification_app.app_name);
            }

            notification_app.notify["app-name"].connect(() => {
                image.set_from_gicon(notification_app.icon, Gtk.IconSize.BUTTON);
            });

            notification_app.notify["icon"].connect(() => {
                label.set_label(notification_app.app_name);
            });

            notification_app.notify["unread-notifications"].connect(() => {
                notifications_unread_frame.set_visible(notification_app.unread_notifications > 0);
                notifications_unread_label.set_label(notification_app.unread_notifications.to_string());

                if (notification_app.unread_notifications > 0) {
                    label.set_markup("<b>" + notification_app.app_name + "</b>");
                } else {
                    label.set_label(notification_app.app_name);
                }
            });
        }
    }

    private string? filter_text;

    public signal void selection_changed(NotificationApp? notification_app);

    construct {
        set_header_func(update_header);
        set_filter_func(filter);

        /* FIXME: get the napps as a property to not depend on the app? */
        var app = GLib.Application.get_default() as Application;

        foreach (var napp in app.notification_apps) {
            var row = new AppRow(napp);
            add(row);
        }

        app.notification_app_added.connect((napp) => {
            var row = new AppRow(napp);
            add(row);
        });
    }

    private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        row.set_header(before != null ? new Gtk.Separator(Gtk.Orientation.HORIZONTAL) : null);
    }

    private bool filter(Gtk.ListBoxRow row) {
        return filter_text != null ? ((AppRow)row).notification_app.app_name.down().contains(filter_text) : true;
    }

    public override void row_selected(Gtk.ListBoxRow? row) {
        var app_row = row as AppRow;
        var notification_app = app_row != null ? app_row.notification_app : null;

        selection_changed(notification_app);
    }

    public void set_filter_text(string text) {
        filter_text = text.down();

        invalidate_filter();
    }
}

} // namespace Nuntius

/* ex:set ts=4 et: */
