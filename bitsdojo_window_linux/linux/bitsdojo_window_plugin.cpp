// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include "include/bitsdojo_window_linux/bitsdojo_window_plugin.h"

#include <cmath>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <glib-object.h>
#include <atomic>
#include "./window_impl.h"

const char kChannelName[] = "bitsdojo/window";
const char kDragAppWindowMethod[] = "dragAppWindow";

struct _FlBitsdojoWindowPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;

  // Connection to Flutter engine.
  FlMethodChannel* channel;
  // Cached top-level window and realize handler for readiness.
  GtkWindow* cached_window;
  gulong realize_handler;
};

G_DEFINE_TYPE(FlBitsdojoWindowPlugin, bitsdojo_window_plugin, g_object_get_type())

// Global plugin pointer guarded atomically to avoid init reordering races.
static std::atomic<FlBitsdojoWindowPlugin*> g_plugin{nullptr};

// Gets the top level window being controlled.
GtkWindow* get_window(FlBitsdojoWindowPlugin* self) {
    if (self == nullptr || self->registrar == nullptr) return nullptr;
    if (self->cached_window != nullptr) return self->cached_window;

    FlView* view = fl_plugin_registrar_get_view(self->registrar);
    if (view == nullptr) return nullptr;
    GtkWidget* widget = GTK_WIDGET(view);
    GtkWidget* toplevel = gtk_widget_get_toplevel(widget);
    if (!GTK_IS_WINDOW(toplevel)) return nullptr;
    self->cached_window = GTK_WINDOW(toplevel);
    return self->cached_window;
}

GtkWindow* getAppWindowHandle(){
    FlBitsdojoWindowPlugin* p = g_plugin.load(std::memory_order_acquire);
    if (!p) {
        static std::atomic_flag warned = ATOMIC_FLAG_INIT;
        if (!warned.test_and_set()) g_warning("bitsdojo_window: plugin not initialized yet");
        return nullptr;
    }
    auto* win = get_window(p);
    if (!win) {
        static std::atomic_flag warned2 = ATOMIC_FLAG_INIT;
        if (!warned2.test_and_set()) g_warning("bitsdojo_window: GTK view not realized yet");
    }
    return win;
}

static FlMethodResponse* start_window_drag_at_position(FlBitsdojoWindowPlugin *self, FlValue *args) {
	auto window = get_window(self);
  startWindowDrag(window);
	return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

// Called when a method call is received from Flutter.
static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(user_data);

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, kDragAppWindowMethod) == 0) {
    response = start_window_drag_at_position(self, args);
  }
  else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error))
    g_warning("Failed to send method call response: %s", error->message);
}

static void bitsdojo_window_plugin_dispose(GObject* object) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(object);

  g_clear_object(&self->registrar);
  g_clear_object(&self->channel);

  G_OBJECT_CLASS(bitsdojo_window_plugin_parent_class)->dispose(object);
}

static void bitsdojo_window_plugin_class_init(FlBitsdojoWindowPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = bitsdojo_window_plugin_dispose;
}

static void bitsdojo_window_plugin_init(FlBitsdojoWindowPlugin* self) {
    self->cached_window = nullptr;
    self->realize_handler = 0;
    // publish plugin after constructed; registrar set in new()
}

FlBitsdojoWindowPlugin* bitsdojo_window_plugin_new(FlPluginRegistrar* registrar) {
  FlBitsdojoWindowPlugin* self = FL_BITSDOJO_WINDOW_PLUGIN(
      g_object_new(bitsdojo_window_plugin_get_type(), nullptr));


  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  // Mark plugin as ready for external loads.
  g_plugin.store(self, std::memory_order_release);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->channel, method_call_cb,
                                            g_object_ref(self), g_object_unref);

  return self;
}

void bitsdojo_window_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlBitsdojoWindowPlugin* plugin = bitsdojo_window_plugin_new(registrar);
  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);
  if (view) {
    GtkWidget* widget = GTK_WIDGET(view);
    if (gtk_widget_get_realized(widget)) {
      plugin->cached_window = GTK_WINDOW(gtk_widget_get_toplevel(widget));
    } else {
      plugin->realize_handler = g_signal_connect(
          widget, "realize",
          G_CALLBACK(+[](GtkWidget* w, gpointer user_data) {
            auto* pl = static_cast<FlBitsdojoWindowPlugin*>(user_data);
            pl->cached_window = GTK_WINDOW(gtk_widget_get_toplevel(w));
          }),
          plugin);
    }
    enhanceFlutterView(GTK_WIDGET(view));
  }
  g_object_unref(plugin);
}
