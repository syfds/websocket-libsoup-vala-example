project('com.github.syfds.websocket-libsoup-vala-example', 'vala', 'c',
        version: '0.0.1',
        meson_version: '>=0.42.0')

gtk = dependency('gtk+-3.0')
glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
soup = dependency('libsoup-2.4')

add_project_arguments(['--ccode', '--debug'], language: 'vala')

dependencies = [
    gtk,
    glib, 
    gobject,
    soup
]

src_files = files(['src/Main.vala'])

executable(
    meson.project_name(),
    sources: src_files,
    dependencies: dependencies,
    install: true
)