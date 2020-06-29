public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        this.title = "Colors";
        this.set_default_size (600, 400);

        var header = new Gtk.HeaderBar ();
        header.show_title_buttons = true;
        this.set_titlebar (header);

        var scrolled_win = new Gtk.ScrolledWindow ();
        this.set_child (scrolled_win);

        var grid_view = new Gtk.GridView ();
        grid_view.set_hscroll_policy (Gtk.ScrollablePolicy.NATURAL);
        grid_view.set_vscroll_policy (Gtk.ScrollablePolicy.NATURAL);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_simple_listitem_cb);
        grid_view.set_factory (factory);

        grid_view.set_max_columns (24);
        grid_view.set_enable_rubberband (true);

        var color_list_model = new ColorListModel (0);
        var sort_model = new Gtk.SortListModel (color_list_model, null);

        var selection = new Gtk.MultiSelection (sort_model);
        grid_view.set_model (selection);

        scrolled_win.set_child (grid_view);

        var refill_button = new Gtk.Button.with_mnemonic ("_Refill");
        refill_button.clicked.connect ((btn) => {
            color_list_model.size = 0;
            btn.add_tick_callback (add_colors);
        });

        header.pack_start (refill_button);
    }

    void setup_simple_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem item) {
        var expression = new Gtk.ConstantExpression.for_value (item);
        var color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        var picture = new Gtk.Picture ();
        picture.set_size_request (32, 32);
        color_expression.bind (picture, "paintable", null);
        item.set_child (picture);
    }

    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        item.set_child (box);

        Gtk.Expression expression, color_expression;
        Gtk.Expression[1] params = {};

        expression = new Gtk.ConstantExpression.for_value (item);
        color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), color_expression.ref (), "color-name");

        var name_label = new Gtk.Label (null);
        expression.bind (name_label, "label", name_label);

        box.append (name_label);

        expression = color_expression.ref ();
        var picture = new Gtk.Picture ();
        expression.bind (picture, "paintable", picture);

        box.append (picture);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (GLib.Callback)ColorWidget.get_rgb_markup);

        var rgb_label = new Gtk.Label (null);
        rgb_label.set_use_markup (true);
        expression.bind (rgb_label, "label", rgb_label);

        box.append (rgb_label);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (GLib.Callback)ColorWidget.get_hsv_markup);

        var hsv_label = new Gtk.Label (null);
        hsv_label.set_use_markup (true);
        expression.bind (hsv_label, "label", hsv_label);

        box.append (hsv_label);
    }

    bool add_colors (Gtk.Widget widget, Gdk.FrameClock clock, GLib.Variant data) {
        data.get_data ("limit");
        return GLib.Source.CONTINUE;
    }
}