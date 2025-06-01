import Hyprland from "gi://AstalHyprland";
import { bind, exec } from "astal";
import Network from "gi://AstalNetwork";
import Wp from "gi://AstalWp";
import Battery from "gi://AstalBattery";
import { Gdk, Astal, App, Gtk } from "astal/gtk4";

// TODO: Add all of the following modules:
// - [x] workspaces
// - [x] currently focused window
// - [ ] tray
// - [ ] media
// - [ ] network
// - [x] volume
// - [x] power menu

function Workspaces() {
  const hyprland = Hyprland.get_default();

  return (
    <box>
      {bind(hyprland, "workspaces").as((w) =>
        w
          .filter((w) => !(w.id >= -99 && w.id <= -2)) // filters out special workspaces
          .sort((a, b) => a.id - b.id)
          .map((w) => <button onClicked={() => w.focus()}>{w.id}</button>),
      )}
    </box>
  );
}

function Window() {
  const hyprland = Hyprland.get_default();
  const focusedClient = bind(hyprland, "focusedClient");

  // TODO:
  // - add the app icon of the focused client
  return (
    <box visible={focusedClient.as(Boolean)}>
      {focusedClient.as(
        (c) => c && <label label={bind(c, "title").as(String)} />,
      )}
    </box>
  );
}

function Wifi() {
  const network = Network.get_default();
  const wifi = bind(network, "wifi");

  return (
    <box visible={wifi.as(Boolean)}>
      {wifi.as(
        (w) =>
          w && (
            <image
              iconName={bind(w, "iconName")}
              tooltipText={bind(w, "ssid")}
            />
          ),
      )}
    </box>
  );
}

function Volume() {
  const defaultSpeaker = Wp.get_default()?.audio.defaultSpeaker;

  // TODO:
  // - make a slider appear when you hover over the module
  return (
    <box>
      <image iconName={bind(defaultSpeaker!, "volumeIcon")} />
      <label
        label={bind(defaultSpeaker!, "volume").as(
          (v) => `${Math.round(v * 100)}%`,
        )}
      />
    </box>
  );
}

function BatteryPercentage() {
  const battery = Battery.get_default();

  return (
    <box visible={bind(battery, "isPresent")}>
      <image iconName={bind(battery, "iconName")} />
      <label
        label={bind(battery, "percentage").as((p) => `${Math.round(p * 100)}%`)}
      />
    </box>
  );
}

function Power() {
  return (
    <box>
      <button onClicked={() => exec("wlogout")}>
        <image iconName={"system-log-out"} />
      </button>
    </box>
  );
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      cssClasses={["Bar"]}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox cssName="centerbox">
        <box hexpand halign={Gtk.Align.START}>
          <Workspaces />
        </box>
        <box>
          <Window />
        </box>
        <box hexpand halign={Gtk.Align.END}>
          <Wifi />
          <Volume />
          <BatteryPercentage />
          <Power />
        </box>
      </centerbox>
    </window>
  );
}
