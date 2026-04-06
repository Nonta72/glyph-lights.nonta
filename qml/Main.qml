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

    property bool glyphOn: false
    property bool busy: false

    Python {
        id: python

        Component.onCompleted: {
            // Add the qml/ directory so glyph.py is importable
            addImportPath(Qt.resolvedUrl('.'));
            importModule('glyph', function() {
                // Read last known state once the module is loaded
                python.call('glyph.get_glyph_state', [], function(state) {
                    root.glyphOn = state;
                });
            });
        }

        onError: {
            console.log("PyOtherSide error: " + traceback);
            root.busy = false;
        }
    }

    function toggleGlyph() {
        if (root.busy) return;
        root.busy = true;
        var next = root.glyphOn ? 'off' : 'on';
        python.call('glyph.set_glyph', [next], function(success) {
            if (success) {
                root.glyphOn = !root.glyphOn;
            }
            root.busy = false;
        });
    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: pageHeader
            title: "Nothing Glyphs"
        }

        ColumnLayout {
            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            spacing: units.gu(4)

            Item { Layout.fillHeight: true }

            // Glyph visual indicator
            Rectangle {
                id: glyphVisual
                Layout.alignment: Qt.AlignHCenter
                width: units.gu(20)
                height: units.gu(20)
                radius: width / 2
                color: root.glyphOn ? "#ffffff" : "#222222"
                border.color: root.glyphOn ? "#ffffff" : "#555555"
                border.width: units.gu(0.3)

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.6
                    height: parent.height * 0.6
                    radius: width / 2
                    color: root.glyphOn ? "#eeeeee" : "#333333"

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: root.busy ? "..." : (root.glyphOn ? "ON" : "OFF")
                        font.pixelSize: units.gu(3)
                        font.bold: true
                        color: root.glyphOn ? "#000000" : "#888888"

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }
                }
            }

            // Toggle button
            Button {
                id: toggleButton
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: units.gu(28)
                Layout.preferredHeight: units.gu(7)
                enabled: !root.busy
                text: root.busy ? "Please wait..." : (root.glyphOn ? "Turn Glyphs OFF" : "Turn Glyphs ON")
                color: root.glyphOn ? UbuntuColors.red : UbuntuColors.green

                onClicked: root.toggleGlyph()
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
