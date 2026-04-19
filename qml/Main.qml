import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3
import io.thp.pyotherside 1.5

MainView {
    id: root
    objectName: "mainView"
    applicationName: "glyph-lights.nonta"
    automaticOrientation: true
    width: units.gu(45)
    height: units.gu(75)

    // 0 = off, 1–4095 = brightness level
    property int brightness: 0
    property bool busy: false
    property bool glyphOn: brightness > 0

    Python {
        id: python

        Component.onCompleted: {
		  // Add the qml/ directory so glyph.py is importable
            addImportPath(Qt.resolvedUrl('.'));
            importModule('glyph', function() {
                python.call('glyph.get_glyph_brightness', [], function(val) {
                    root.brightness = val;
                    // Sync slider without triggering a write
                    brightnessSlider.value = val;
                });
            });
        }

        onError: {
            console.log("PyOtherSide error: " + traceback);
            root.busy = false;
        }
    }

    function applyBrightness(val) {
        if (root.busy) return;
        root.busy = true;
        python.call('glyph.set_glyph', [val], function(success) {
            if (success) root.brightness = val;
            root.busy = false;
        });
    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: pageHeader
            title: "Glyph Lights"
        }

        ColumnLayout {
            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(3)
            }
            spacing: units.gu(3)

            Item { Layout.fillHeight: true }

            // Glyph visual indicator — brightness reflected in opacity
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: units.gu(20)
                height: units.gu(20)
                radius: width / 2
                color: "#222222"
                border.color: "#555555"
                border.width: units.gu(0.3)

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.6
                    height: parent.height * 0.6
                    radius: width / 2
                    color: "#ffffff"
                    opacity: root.brightness / 4095.0

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: root.busy ? "..." : (root.glyphOn ? root.brightness : "OFF")
                    font.pixelSize: units.gu(2.5)
                    font.bold: true
                    color: root.glyphOn ? "#ffffff" : "#888888"
                    z: 1
                }
            }

            // Brightness slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: units.gu(1)

                Label {
                    text: "Brightness"
                    color: UbuntuColors.coolGrey
                    font.pixelSize: units.gu(1.8)
                }

                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 4095
                    stepSize: 1
                    value: root.brightness
                    enabled: !root.busy

                    // Only write to device when user releases the slider
                    onPressedChanged: {
                        if (!pressed) {
                            root.applyBrightness(Math.round(value));
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Off"
                        color: UbuntuColors.coolGrey
                        font.pixelSize: units.gu(1.5)
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "Max"
                        color: UbuntuColors.coolGrey
                        font.pixelSize: units.gu(1.5)
                    }
                }
            }

            // Quick buttons row
            RowLayout {
                Layout.fillWidth: true
                spacing: units.gu(2)

                Button {
                    Layout.fillWidth: true
                    text: "OFF"
                    enabled: !root.busy
                    color: UbuntuColors.red
                    onClicked: {
                        brightnessSlider.value = 0;
                        root.applyBrightness(0);
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "25%"
                    enabled: !root.busy
                    onClicked: {
                        brightnessSlider.value = 1024;
                        root.applyBrightness(1024);
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "50%"
                    enabled: !root.busy
                    onClicked: {
                        brightnessSlider.value = 2048;
                        root.applyBrightness(2048);
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "MAX"
                    enabled: !root.busy
                    color: UbuntuColors.green
                    onClicked: {
                        brightnessSlider.value = 4095;
                        root.applyBrightness(4095);
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Tap the button above to turn ON/OFF glyphs lights."
                color: UbuntuColors.coolGrey
                font.pixelSize: units.gu(1.6)
            }

            Item { Layout.fillHeight: true }
        }
    }
}
