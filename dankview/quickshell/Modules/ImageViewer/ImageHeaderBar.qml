import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property var windowControls: null
    property var targetWindow: null

    height: 52
    color: Theme.withAlpha(Theme.cardSurface, 0.90)
    border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
    border.width: 1

    // Drag header to move window
    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (root.windowControls)
                root.windowControls.tryStartMove();
        }
        onDoubleClicked: {
            if (root.windowControls)
                root.windowControls.tryToggleMaximize();
        }
    }

    component WindowButton: DankActionButton {
        buttonSize: Theme.buttonHeightXXS
        iconSize: Theme.iconSizeSmall
        iconColor: Theme.surfaceText
    }

    // Left: Navigation & Filename
    RowLayout {
        id: leftRow
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: centerGroup.visible ? centerGroup.left : rightRow.left
        anchors.rightMargin: 12
        spacing: 10

        // Leading Icon / Navigation button (always present to prevent layout shift)
        DankActionButton {
            readonly property bool canGoBack: !ImageService.galleryMode
            iconName: canGoBack ? "arrow_back" : "image"
            iconSize: 20
            buttonSize: 32
            enabled: canGoBack
            iconColor: canGoBack ? Theme.surfaceText : Theme.primary
            tooltipText: canGoBack ? "Back to Gallery (Esc)" : ""
            tooltipSide: "bottom"
            onClicked: {
                if (canGoBack) {
                    ImageService.backToGallery();
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: ImageService.galleryMode ? "Gallery" : (ImageService.currentFileName || "DankView")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.DemiBold
            color: Theme.surfaceText
            elide: Text.ElideMiddle
        }
    }

    // Center: Playback, Counter Badge & Zoom Pill (exactly centered in header)
    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: 8
        visible: !ImageService.galleryMode

        // Center: Animated Image Play/Pause Control
        Rectangle {
            visible: ImageService.isAnimated
            implicitHeight: 30
            implicitWidth: playPauseRow.implicitWidth + 16
            Layout.alignment: Qt.AlignVCenter
            radius: 15
            color: playPauseMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

            RowLayout {
                id: playPauseRow
                anchors.centerIn: parent
                spacing: 4

                DankIcon {
                    name: ImageService.isPlaying ? "pause" : "play_arrow"
                    size: 18
                    color: Theme.primary
                }

                Text {
                    text: ImageService.isPlaying ? "Pause" : "Play"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            MouseArea {
                id: playPauseMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.togglePlayback()
            }
        }

        // Center: Counter badge e.g. "3 / 12"
        Rectangle {
            visible: ImageService.fileList.length > 0
            implicitHeight: 28
            implicitWidth: counterText.implicitWidth + 20
            Layout.alignment: Qt.AlignVCenter
            radius: 14
            color: Theme.surfaceContainerHighest

            Text {
                id: counterText
                anchors.centerIn: parent
                text: (ImageService.currentIndex + 1) + " / " + ImageService.fileList.length
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
            }
        }

        // Center: Zoom Pill (Scroll to Zoom, Click to Reset)
        Rectangle {
            id: zoomPill
            visible: ImageService.currentFilePath !== ""
            implicitHeight: 28
            implicitWidth: zoomPillRow.implicitWidth + 20
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.cornerRadiusFull
            color: zoomMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.25)
            border.width: 1

            RowLayout {
                id: zoomPillRow
                anchors.centerIn: parent
                spacing: 4

                DankIcon {
                    name: "zoom_in"
                    size: 15
                    color: Theme.surfaceVariantText
                }

                Text {
                    text: Math.round(ImageService.zoom * 100) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            MouseArea {
                id: zoomMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ImageService.resetZoom()
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        ImageService.zoomIn();
                    } else if (wheel.angleDelta.y < 0) {
                        ImageService.zoomOut();
                    }
                }
            }

            DankTooltipHost {
                text: "Scroll to zoom • Click to reset"
                target: zoomPill
                hoverArea: zoomMouse
                side: "bottom"
            }
        }
    }

    // Right: Actions & Window Controls
    RowLayout {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Favorite / Like Image
        DankActionButton {
            visible: ImageService.currentFilePath !== "" && !ImageService.galleryMode
            readonly property bool isFav: ImageService.isFavorite(ImageService.currentFilePath)
            iconName: isFav ? "favorite" : "favorite_border"
            iconSize: 19
            iconColor: isFav ? Theme.error : Theme.surfaceText
            tooltipText: isFav ? "Remove from Favorites (F)" : "Add to Favorites (F)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleFavorite(ImageService.currentFilePath)
        }

        // Image Info / EXIF Inspector
        DankActionButton {
            visible: ImageService.currentFilePath !== "" && !ImageService.galleryMode
            iconName: "info"
            iconSize: 19
            iconColor: ImageService.inspectorOpen ? Theme.primary : Theme.surfaceText
            tooltipText: "Image Info / EXIF (I)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleInspector()
        }

        // Lock UI / Zen View
        DankActionButton {
            visible: ImageService.currentFilePath !== "" && !ImageService.galleryMode
            iconName: "lock_open"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: "Lock UI / Clean View (K)"
            tooltipSide: "bottom"
            onClicked: ImageService.toggleLockUI()
        }

        // Open File Action (placed on the far right to maintain stable position)
        DankActionButton {
            iconName: "folder_open"
            iconSize: 19
            iconColor: Theme.surfaceText
            tooltipText: "Open Image (O / Ctrl+O)"
            tooltipSide: "bottom"
            onClicked: ImageService.openFileDialog()
        }

        Rectangle {
            visible: root.windowControls?.canMinimize ?? false
            implicitWidth: 1
            implicitHeight: 20
            Layout.alignment: Qt.AlignVCenter
            color: Theme.outlineVariant
            opacity: 0.4
        }

        // Window Controls (minimize)
        WindowButton {
            visible: root.windowControls?.canMinimize ?? false
            iconName: "minimize"
            tooltipText: "Minimize"
            tooltipSide: "bottom"
            onClicked: {
                if (root.windowControls)
                    root.windowControls.tryMinimize();
            }
        }
    }
}
