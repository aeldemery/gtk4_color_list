public class Gtk4Demo.ColorWidget : GLib.Object, Gdk.Paintable {

    public ColorWidget (string name, float r, float g, float b) {
        _color = { r, g, b, 1.0f };
        this.color_name = name;
        this.color = _color;
    }

    // Properties
    public string color_name { get; set; }

    private Gdk.RGBA _color = { 1f, 1f, 1f, 1f };
    public Gdk.RGBA color {
        get {
            return _color;
        }
        set {
            _color = value;
            double h_local, s_local, v_local;
            rgb_to_hsv (_color, out h_local, out s_local, out v_local);
            _hue = (int) GLib.Math.round (360 * h_local);
            _saturation = (int) GLib.Math.round (100 * s_local);
            _value = (int) GLib.Math.round (100 * v_local);
        }
    }

    public float red {
        get {
            return _color.red;
        }
    }

    public float green {
        get {
            return _color.green;
        }
    }

    public float blue {
        get {
            return _color.blue;
        }
    }

    public int hue {
        get; default = 360;
    }

    public int saturation {
        get; default = 100;
    }

    public int value {
        get; default = 100;
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        ((Gtk.Snapshot)snapshot).append_color (this.color, { { 0, 0 }, { (float) width, (float) height } });
    }

    public int get_intrinsic_height () {
        return 32;
    }

    public int get_intrinsic_width () {
        return 32;
    }

    public static void rgb_to_hsv (Gdk.RGBA rgba, out double h_out, out double s_out, out double v_out) {
        Gtk.rgb_to_hsv (rgba.red, rgba.green, rgba.blue, out h_out, out s_out, out v_out);
    }

    public static string ? get_rgb_markup (ColorWidget ? color) {
        if (color == null) return null;
        return "<b>R:</b> %d <b>G:</b> %d <b>B:</b> %d".printf (
            (int) (color.red * 255),
            (int) (color.green * 255),
            (int) (color.blue * 255)
        );
    }

    public static string ? get_hsv_markup (ColorWidget ? color) {
        if (color == null) return null;
        return "<b>H:</b> %d <b>S:</b> %d <b>V:</b> %d".printf (
            color.hue,
            color.saturation,
            color.value
        );
    }
}