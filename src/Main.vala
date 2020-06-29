public const int N_COLORS = 256 * 256 * 256;

int main (string[] args) {
    var app = new Gtk4Demo.ColorListDemoApp ();
    return app.run (args);
}

public class Gtk4Demo.ColorListDemoApp : Gtk.Application {
    public ColorListDemoApp () {
        Object (
            application_id: "github.aeldemery.gtk4_color_list",
            flags : GLib.ApplicationFlags.FLAGS_NONE
        );
    }

    public override void activate () {
        var win = this.active_window;
        if (win == null) {
            win = new Gtk4Demo.MainWindow (this);
        }
        win.present ();
    }
}