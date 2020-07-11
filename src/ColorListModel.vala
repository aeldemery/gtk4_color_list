public const int N_COLORS = 256 * 256 * 256;

public class Gtk4Demo.ColorListModel : GLib.Object, GLib.ListModel {

    public ColorListModel (uint size) {
        this.size = size;
    }

    static construct {
        colors = new ColorWidget[N_COLORS];
        try {
            var data = GLib.resources_lookup_data (
                "/github/aeldemery/gtk4_color_list/color.names.txt",
                GLib.ResourceLookupFlags.NONE
            );

            var lines = ((string) data).split ("\n");
            int i = 0;
            foreach (var line in lines) {
                if (line.has_prefix ("#") || line.has_prefix ("\0")) {
                    continue;
                }
                var fields = line.split (" ");
                var name = fields[1];

                var red = int.parse (fields[3]);
                var green = int.parse (fields[4]);
                var blue = int.parse (fields[5]);

                var pos = ((red & 0xFF) << 16) | ((green & 0xFF) << 8) | blue;

                if (colors[pos] == null) {
                    colors[pos] = new ColorWidget (name, red / 255, green / 255, blue / 255);
                }
            }
        } catch (GLib.Error error) {
            critical ("Error occured in ColorListModel, error: %s\n", error.message);
        }
    }

    private static ColorWidget[] colors = null; /* Internal Data for the ListModel */

    private uint _size;
    public uint size {
        get {
            return _size;
        }
        set {
            uint old_size = _size;
            _size = value;

            if (_size > old_size) {
                items_changed (old_size, 0, _size - old_size);
            } else if (old_size > _size) {
                items_changed (_size, old_size - _size, 0);
            }

            notify_property ("size");
        }
    }

    public GLib.Object ? get_item (uint position)
    requires (position < size && position >= 0) /* One less than size */
    {
        var pos = position_to_color (position);

        if (colors[pos] == null) {
            uint red, green, blue;
            red = (pos >> 16) & 0xFF;
            green = (pos >> 8) & 0xFF;
            blue = pos & 0xFF;

            colors[pos] = new ColorWidget ("", red / 255, green / 255, blue / 255);
        }

        return colors[pos];
    }

    public GLib.Type get_item_type () {
        return typeof (ColorWidget);
    }

    public uint get_n_items () {
        return size;
    }

    public uint position_to_color (uint position) {
        var map = new uint[] {
            0xFF0000, 0x00FF00, 0x0000FF,
            0x7F0000, 0x007F00, 0x00007F,
            0x3F0000, 0x003F00, 0x00003F,
            0x1F0000, 0x001F00, 0x00001F,
            0x0F0000, 0x000F00, 0x00000F,
            0x070000, 0x000700, 0x000007,
            0x030000, 0x000300, 0x000003,
            0x010000, 0x000100, 0x000001
        };
        uint i = 0, result = 0;
        foreach (var element in map) {
            if ((position & (1 << i)) > 0) {
                result ^= map[i];
                i++;
            }
        }
        return result;
    }
}
