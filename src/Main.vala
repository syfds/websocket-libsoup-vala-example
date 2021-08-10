using Gtk;

class WebsocketConnection {
    private Soup.WebsocketConnection websocket_connection;
    public signal void ws_message(int type, string message);
    public signal void connection_succeeded();
    public signal void connection_established();
    public signal void connection_failed();
    public signal void connection_disengaged();

    private string host;

    public WebsocketConnection(string host) {
        this.host = host;
    }

    private static string decode_bytes(Bytes byt, int n) {
        return (string)byt.get_data();
    }

    public async void init_connection_for(string host) {
        var socket_client = new Soup.Session();

        string url = "wss://%s/".printf(host);
        message(@"connect to $url");
        var websocket_message = new Soup.Message("GET", url);
        websocket_connection = yield socket_client.websocket_connect_async(websocket_message, null, null, null);
        try {
            message("Connected!");

            connection_succeeded();
            if (websocket_connection != null) {
                websocket_connection.message.connect((type, m_message) => {
                    ws_message(type, decode_bytes(m_message, m_message.length));
                });
                websocket_connection.closed.connect(() => {
                    message("Connection closed");
                    connection_disengaged();
                });
            }
        } catch (Error e) {
            message("Remote error: " + e.message + " " + e.code.to_string());
            connection_failed();
        }

    }

    public void send(string string) {
        websocket_connection.send_text(string);
    }
}


class Main : Gtk.Application {

    static WebsocketConnection connection;

    public Main() {
        Object(
                application_id: "com.github.syfds.websocket-libsoup-vala-example",
                flags : ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {

        var window = new ApplicationWindow(this);
        window.title = "Hello, World!";
        window.border_width = 10;
        window.window_position = WindowPosition.CENTER;
        window.set_default_size(350, 70);

        var grid  = new Grid();
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.orientation = Orientation.VERTICAL;
        grid.column_spacing = 5;
        grid.row_spacing = 5;
        var main_label = new Label("...");
        var websocket_host_input = new Entry();
        var send_message_btn = new Button.with_label("Send message");
        send_message_btn.clicked.connect(() => {
            string text =  websocket_host_input.get_text();
            message("sending " + text + " to echo server using websockets");
            connection.send(text);
        });

        var websocket_host = "echo.websocket.org";
        connection = new WebsocketConnection(websocket_host);

        connection.connection_succeeded.connect(() => {
            message("Connection succeeded");
            main_label.set_text("Connection succeeded");
            connection.send("hello");
        });
        connection.connection_failed.connect(() => {
            message("Connection failed");
        });

        connection.ws_message.connect((type, msg) => {
            message("message received " + msg);
            main_label.set_text("Got from echo server " + msg);
        });

        connection.init_connection_for.begin(websocket_host);


        grid.add(main_label);
        grid.add(websocket_host_input);
        grid.add(send_message_btn);

        window.add(grid);
        window.show_all();
    }

    public static int main(string[] args) {
        var app = new Main();
        return app.run(args);
    }
}
