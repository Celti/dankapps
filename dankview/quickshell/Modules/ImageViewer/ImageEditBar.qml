import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property var cropOverlay: null

    implicitHeight: 46
    implicitWidth: (ImageService.cropMode ? cropRow.implicitWidth : editRow.implicitWidth) + 24
    radius: 23
    color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.95)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.30)
    border.width: 1
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }

    component BarButton: Rectangle {
        id: btn
        property string iconName: ""
        property real iconRotation: 0
        property string tooltipText: ""
        property bool isActive: false
        property color iconColor: isActive ? Theme.primary : Theme.surfaceText
        signal clicked()

        implicitWidth: 36
        implicitHeight: 36
        radius: 18
        color: isActive ? Theme.primaryContainer : (btnMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        DankIcon {
            anchors.centerIn: parent
            name: btn.iconName
            rotation: btn.iconRotation
            size: 20
            color: btn.iconColor
        }

        StateLayer {
            id: btnMouse
            cornerRadius: btn.radius
            stateColor: Theme.primary
            tooltipText: btn.tooltipText
            tooltipSide: "top"
            onClicked: btn.clicked()
        }
    }

    component BarSeparator: Rectangle {
        implicitWidth: 1
        implicitHeight: 20
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        color: Theme.outlineVariant
        opacity: 0.35
    }

    // Normal editing tools row
    RowLayout {
        id: editRow
        anchors.centerIn: parent
        spacing: 4
        opacity: !ImageService.cropMode ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }

        // Group 1: Rotation
        BarButton {
            iconName: "rotate_left"
            tooltipText: "Rotate Counter-Clockwise (L / Shift+R)"
            onClicked: ImageService.rotateCounterClockwise()
        }

        BarButton {
            iconName: "rotate_right"
            tooltipText: "Rotate Clockwise (R)"
            onClicked: ImageService.rotateClockwise()
        }

        BarSeparator {}

        // Group 2: Flip
        BarButton {
            iconName: "flip"
            tooltipText: "Flip Horizontally (H / M)"
            onClicked: ImageService.toggleFlipHorizontal()
        }

        BarButton {
            iconName: "flip"
            iconRotation: 90
            tooltipText: "Flip Vertically (V)"
            onClicked: ImageService.toggleFlipVertical()
        }

        BarSeparator {}

        // Group 3: Crop
        BarButton {
            iconName: "crop"
            tooltipText: "Crop Image (X)"
            isActive: ImageService.cropMode
            onClicked: ImageService.toggleCropMode()
        }

        BarSeparator {
            visible: ImageService.isAnimated
        }

        // Animated image playback control
        BarButton {
            visible: ImageService.isAnimated
            iconName: ImageService.isPlaying ? "pause" : "play_arrow"
            tooltipText: ImageService.isPlaying ? "Pause Animation (Space)" : "Play Animation (Space)"
            onClicked: ImageService.togglePlayback()
        }

        BarSeparator {}

        // Group 4: Zoom Controls
        BarButton {
            iconName: "zoom_out"
            tooltipText: "Zoom Out (-)"
            onClicked: ImageService.zoomOut()
        }

        BarButton {
            iconName: "zoom_in"
            tooltipText: "Zoom In (+)"
            onClicked: ImageService.zoomIn()
        }

        BarButton {
            iconName: "crop_free"
            tooltipText: "Fit to Window (0)"
            onClicked: ImageService.fitToWindow()
        }

        BarSeparator {}

        // Group 5: Delete / Trash
        BarButton {
            iconName: "delete"
            tooltipText: "Move to Trash (Delete)"
            iconColor: Theme.error
            onClicked: ImageService.moveToTrash()
        }

        BarSeparator {}

        // Group 6: Done / Close Button
        Rectangle {
            implicitWidth: doneBtnRow.implicitWidth + 20
            implicitHeight: 34
            radius: 17
            color: doneMouse.containsMouse
                ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.88)
                : Theme.primary

            Behavior on color { ColorAnimation { duration: 100 } }

            RowLayout {
                id: doneBtnRow
                anchors.centerIn: parent
                spacing: 5

                DankIcon {
                    name: "check"
                    size: 16
                    color: Theme.onPrimary || Theme.primaryText
                }

                Text {
                    text: "Done"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.onPrimary || Theme.primaryText
                }
            }

            StateLayer {
                id: doneMouse
                cornerRadius: 17
                stateColor: Theme.onPrimary || Theme.primaryText
                tooltipText: "Done Editing (E / Esc)"
                tooltipSide: "top"
                onClicked: ImageService.toggleEditMode()
            }
        }
    }

    // Morphed Crop Controls Row
    RowLayout {
        id: cropRow
        anchors.centerIn: parent
        spacing: 4
        opacity: ImageService.cropMode ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }

        // Aspect ratio presets
        Repeater {
            model: [
                { label: "Free",  ar: "" },
                { label: "1:1",   ar: "1:1" },
                { label: "4:3",   ar: "4:3" },
                { label: "16:9",  ar: "16:9" },
                { label: "3:2",   ar: "3:2" }
            ]
            delegate: Rectangle {
                readonly property bool isSelected: root.cropOverlay ? root.cropOverlay.aspectRatio === modelData.ar : false
                implicitWidth: arLabel.implicitWidth + 14
                implicitHeight: 32
                radius: 8
                color: isSelected
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                    : (arMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent")
                border.color: isSelected
                    ? Theme.primary
                    : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
                border.width: 1

                Text {
                    id: arLabel
                    anchors.centerIn: parent
                    text: modelData.label
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: isSelected ? Theme.primary : Theme.surfaceText
                }

                StateLayer {
                    id: arMouse
                    cornerRadius: 8
                    stateColor: Theme.primary
                    tooltipSide: "top"
                    onClicked: {
                        if (root.cropOverlay) {
                            root.cropOverlay.aspectRatio = modelData.ar;
                            root.cropOverlay._applyAspect();
                        }
                    }
                }
            }
        }

        BarSeparator {}

        // Reset button
        BarButton {
            iconName: "restart_alt"
            tooltipText: "Reset Crop Selection"
            onClicked: {
                if (root.cropOverlay) {
                    root.cropOverlay.aspectRatio = "";
                    root.cropOverlay.cropX = root.cropOverlay.imageX;
                    root.cropOverlay.cropY = root.cropOverlay.imageY;
                    root.cropOverlay.cropW = root.cropOverlay.imageW;
                    root.cropOverlay.cropH = root.cropOverlay.imageH;
                }
            }
        }

        BarSeparator {}

        // Cancel button
        Rectangle {
            implicitWidth: cancelCropRow.implicitWidth + 18
            implicitHeight: 34
            radius: 17
            color: cancelCropMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)
            border.width: 1

            RowLayout {
                id: cancelCropRow
                anchors.centerIn: parent
                spacing: 4
                DankIcon { name: "close"; size: 16; color: Theme.surfaceText }
                Text {
                    text: "Cancel"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            StateLayer {
                id: cancelCropMouse
                cornerRadius: 17
                stateColor: Theme.surfaceText
                tooltipText: "Cancel Crop (Esc)"
                tooltipSide: "top"
                onClicked: {
                    if (root.cropOverlay)
                        root.cropOverlay.cancelled();
                }
            }
        }

        // Apply / Done button
        Rectangle {
            implicitWidth: applyCropRow.implicitWidth + 18
            implicitHeight: 34
            radius: 17
            color: applyCropMouse.containsMouse
                ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.88)
                : Theme.primary

            Behavior on color { ColorAnimation { duration: 100 } }

            RowLayout {
                id: applyCropRow
                anchors.centerIn: parent
                spacing: 4
                DankIcon { name: "check"; size: 16; color: Theme.onPrimary || Theme.primaryText }
                Text {
                    text: "Done"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.onPrimary || Theme.primaryText
                }
            }

            StateLayer {
                id: applyCropMouse
                cornerRadius: 17
                stateColor: Theme.onPrimary || Theme.primaryText
                tooltipText: "Apply Crop (Enter)"
                tooltipSide: "top"
                onClicked: {
                    if (root.cropOverlay)
                        root.cropOverlay.applyCrop();
                }
            }
        }
    }
}
