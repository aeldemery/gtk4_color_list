project (
    'github.aeldemery.gtk4_color_list',
    'c', 'vala',
    version: '0.1.0',
)

sources = files(
    'src/Main.vala',
    'src/Color.vala',
)

dependencies = [
    dependency ('gtk4'),
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
]

executable (
    meson.project_name(),
    sources: sources,
    dependencies: dependencies,
    install: true,
)