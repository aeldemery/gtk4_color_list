project (
    'github.aeldemery.gtk4_color_list',
    'c', 'vala',
    version: '0.1.0',
)

sources = files(
    'src/Main.vala',
    'src/ColorWidget.vala',
    'src/ColorListModel.vala',
    'src/MainWindow.vala',
)

dependencies = [
    dependency ('gtk4'),
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    meson.get_compiler('c').find_library('m', required: false),
]

gnome = import('gnome')

resources = gnome.compile_resources (
    'as-resources', 'data/github.aeldemery.gtk4_color_list.gresource.xml',
    source_dir: 'data',
    c_name: 'as',
)

executable (
    meson.project_name(),
    resources,
    sources: sources,
    dependencies: dependencies,
    install: true,
)