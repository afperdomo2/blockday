#include <glib.h>

#include "my_application.h"

static gboolean is_known_benign_log_message(const gchar* domain,
                                            const gchar* message) {
  if (g_strcmp0(domain, "Gdk") == 0) {
    return g_strcmp0(message, "Unable to load  from the cursor theme") == 0;
  }
  if (g_strcmp0(domain, "Atk") == 0) {
    return g_strcmp0(
               message,
               "atk_socket_embed: assertion 'plug_id != NULL' failed") == 0;
  }
  return FALSE;
}

static GLogWriterOutput blockday_log_writer(GLogLevelFlags log_level,
                                            const GLogField* fields,
                                            gsize n_fields,
                                            gpointer user_data) {
  const gchar* domain = nullptr;
  const gchar* message = nullptr;

  for (gsize i = 0; i < n_fields; i++) {
    if (g_strcmp0(fields[i].key, "GLIB_DOMAIN") == 0) {
      domain = static_cast<const gchar*>(fields[i].value);
    } else if (g_strcmp0(fields[i].key, "MESSAGE") == 0) {
      message = static_cast<const gchar*>(fields[i].value);
    }
  }

  if (is_known_benign_log_message(domain, message)) {
    return G_LOG_WRITER_HANDLED;
  }

  return g_log_writer_default(log_level, fields, n_fields, user_data);
}

int main(int argc, char** argv) {
  g_log_set_writer_func(blockday_log_writer, nullptr, nullptr);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
