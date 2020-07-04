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

        /*  var refill_button = new Gtk.Button.with_mnemonic ("_Refill");
           refill_button.clicked.connect ((btn) => {
            color_list_model.size = 0;
            btn.add_tick_callback (add_colors);
           });

           header.pack_start (refill_button);  */
    }

    void setup_simple_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var expression = new Gtk.ConstantExpression.for_value (list_item);
        var color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        var picture = new Gtk.Picture ();
        picture.set_size_request (32, 32);
        color_expression.bind (picture, "paintable", null);
        list_item.set_child (picture);
    }

    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        list_item.set_child (box);

        Gtk.Expression expression, color_expression;
        var params = new Gtk.Expression[1];

        expression = new Gtk.ConstantExpression.for_value (list_item);
        color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), color_expression.ref (), "color-name");

        var name_label = new Gtk.Label (null);
        expression.bind (name_label, "label", null);

        box.append (name_label);

        expression = color_expression.ref ();
        var picture = new Gtk.Picture ();
        expression.bind (picture, "paintable", null);

        box.append (picture);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (Callback) ColorWidget.get_rgb_markup, null, null);

        var rgb_label = new Gtk.Label (null);
        rgb_label.set_use_markup (true);
        expression.bind (rgb_label, "label", null);

        box.append (rgb_label);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (Callback) ColorWidget.get_hsv_markup, null, null);

        var hsv_label = new Gtk.Label (null);
        hsv_label.set_use_markup (true);
        expression.bind (hsv_label, "label", null);

        box.append (hsv_label);
    }

    void setup_selection_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        Gtk.Expression expression, color_expression;
        expression = new Gtk.ConstantExpression.for_value (list_item);
        color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        var picture = new Gtk.Picture ();
        picture.set_size_request (8, 8);
        color_expression.bind (picture, "paintable", null);
        list_item.set_child (picture);
    }

    static void set_title (Object item, string title) {
        item.set_data ("title", title);
    }

    static string get_title (Object item) {
        return item.get_data<string>("title");
    }

    Gtk.GridView create_color_grid () {
        var gridview = new Gtk.GridView ();
        with (gridview) {
            hscroll_policy = vscroll_policy = Gtk.ScrollablePolicy.NATURAL;
        }

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_simple_listitem_cb);

        with (gridview) {
            factory = factory;
            max_columns = 24;
            enable_rubberband = true;
        }

        var model = new Gtk.SortListModel (new ColorListModel (0), null);
        var selection = new Gtk.MultiSelection (model);

        gridview.model = selection;

        return gridview;
    }

    static bool add_colors (Gtk.Button widget, Gdk.FrameClock clock, Object data) {
        ColorListModel colors = (ColorListModel) data;
        uint limit;
        limit = data.get_data<uint>("limit");
        colors.size = uint.min (limit, colors.size + uint.max (1, limit / 4096));

        if (colors.size >= limit)
            return GLib.Source.REMOVE;
        else
            return GLib.Source.CONTINUE;
    }

    static void refill (Gtk.Button button, ColorListModel colors) {
        colors.size = 0;
        button.add_tick_callback (add_colors, colors); // Bug
    }
}